---@class Note
---@field id string UUID or timestamp-based unique identifier
---@field title string Note title (usually same as branch name for branch notes)
---@field path string Full filesystem path to the markdown file
---@field project string Git project/repository name
---@field branch string Git branch name
---@field ticket string Ticket/issue identifier (often empty for branch notes)
---@field tags string[] Array of tag strings
---@field created_at string ISO timestamp when note was created (e.g., "2024-01-20 10:30:00")
---@field modified_at string ISO timestamp when note was last modified

---@class JotDatabase
local M = {}

local config = require("jot.config")
local git = require("jot.git")

---Get the path to the jot database
---@return string
local function get_db_path()
    local opts = config.get()
    if opts.db_path then
        return opts.db_path
    end

    local home = vim.fn.expand("~")
    return vim.fn.resolve(home .. "/.jot/notes.db")
end

---Execute a SQL query and return results
---@param query string SQL query to execute
---@param params table|nil Parameters for the query
---@return table|nil results, string|nil error
local function execute_query(query, params)
    local db_path = get_db_path()

    -- Check if database file exists
    if vim.fn.filereadable(db_path) == 0 then
        return nil, "Database file not found: " .. db_path
    end

    -- Build the SQL command for sqlite3
    -- We'll use the sqlite3 command-line tool with JSON output
    local sql_cmd = query
    if params and #params > 0 then
        -- Simple parameter replacement (not ideal for production, but works for our use case)
        for _, param in ipairs(params) do
            -- Escape single quotes in parameters
            local escaped_param = tostring(param):gsub("'", "''")
            sql_cmd = sql_cmd:gsub("%?", "'" .. escaped_param .. "'", 1)
        end
    end

    -- Use sqlite3 with JSON output mode for easier parsing
    local cmd = string.format('sqlite3 -json "%s" "%s"', db_path, sql_cmd)
    local handle = io.popen(cmd)
    if not handle then
        return nil, "Failed to execute sqlite3 command"
    end

    local result = handle:read("*a")
    handle:close()

    -- Parse JSON result
    if result == "" or result == "[]\n" then
        return {}, nil
    end

    -- Try to parse as JSON
    local ok, parsed = pcall(vim.json.decode, result)
    if not ok then
        return nil, "Failed to parse query result: " .. result
    end

    return parsed, nil
end

---Get note for current branch
---@param use_cwd boolean|nil If true, use CWD git context. If false/nil, use current file's git context
---@return Note|nil note The note object for the current branch, or nil if error
---@return string|nil error Error message if operation failed
function M.get_branch_note(use_cwd)
    local project, branch = git.get_context(use_cwd)

    if not project then
        return nil, "Not in a Git repository or unable to determine project name"
    end

    if not branch then
        return nil, "Unable to determine current Git branch"
    end

    local query = "SELECT * FROM notes WHERE project = ? AND branch = ? LIMIT 1"
    local notes, err = execute_query(query, { project, branch })

    if err then
        return nil, err
    end

    if not notes or #notes == 0 then
        -- Note doesn't exist, we need to create it
        return M.create_note(branch, project, branch)
    end

    return notes[1], nil
end

---Create a new branch note
---@param title string Note title
---@param project string Project name
---@param branch string Branch name
---@return Note|nil note The newly created note object, or nil if error
---@return string|nil error Error message if operation failed
function M.create_note(title, project, branch)
    local uuid = vim.fn.system("uuidgen"):gsub("\n", ""):lower()
    if uuid == "" then
        -- Fallback to a simple timestamp-based ID
        uuid = string.format("%s-%s-%d", project, branch, os.time())
    end

    local home = vim.fn.expand("~")
    local notes_dir = home .. "/.jot/notes/" .. project .. "/" .. branch
    local path = notes_dir .. "/" .. title .. ".md"

    -- Create directory structure
    vim.fn.mkdir(notes_dir, "p")

    -- Create the markdown file with basic content
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local content =
        string.format("# %s\n\nCreated: %s\nProject: %s\nBranch: %s\n\n---\n\n", title, timestamp, project, branch)
    vim.fn.writefile(vim.split(content, "\n"), path)

    -- Insert into database
    local insert_query = string.format(
        "INSERT INTO notes (id, title, path, project, branch, ticket, tags, created_at, modified_at) "
            .. "VALUES ('%s', '%s', '%s', '%s', '%s', '', '[]', datetime('now'), datetime('now'))",
        uuid,
        title,
        path,
        project,
        branch
    )

    local db_path = get_db_path()
    local cmd = string.format('sqlite3 "%s" "%s"', db_path, insert_query)
    os.execute(cmd)

    -- Return the created note
    return {
        id = uuid,
        title = title,
        path = path,
        project = project,
        branch = branch,
        ticket = "",
        tags = {},
        created_at = timestamp,
        modified_at = timestamp,
    },
        nil
end

---Search for notes by title or ID
---@param query string Search query
---@return Note[]|nil results Array of matching notes, or nil if error
---@return string|nil error Error message if operation failed
function M.search_notes(query)
    local sql_query = "SELECT * FROM notes WHERE title LIKE ? OR id = ?"
    local search_pattern = "%" .. query .. "%"
    local results, err = execute_query(sql_query, { search_pattern, query })

    if err then
        return nil, err
    end

    return results, nil
end

---Get all notes for current project
---@param use_cwd boolean|nil If true, use CWD git context. If false/nil, use current file's git context
---@return Note[]|nil results Array of notes for the current project, or nil if error
---@return string|nil error Error message if operation failed
function M.get_project_notes(use_cwd)
    local project, _ = git.get_context(use_cwd)
    if not project then
        return nil, "Not in a Git repository or unable to determine project name"
    end

    local query = "SELECT * FROM notes WHERE project = ? ORDER BY modified_at DESC"
    return execute_query(query, { project })
end

return M

