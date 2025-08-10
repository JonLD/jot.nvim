---@class JotCore
local M = {}

local database = require("jot.database")
local git = require("jot.git")

---Open branch note
---@param use_cwd boolean|nil If true, use CWD context instead of current file context
function M.open_branch_note(use_cwd)
    local note, err = database.get_branch_note(use_cwd)
    if err then
        vim.notify("Error:" .. err, vim.log.levels.ERROR)
        return
    elseif note and note.path then
        vim.cmd("edit " .. vim.fn.fnameescape(note.path))
    end
end

---Open specific note by title or ID
---@param query string Note title or ID
function M.open_note(query, use_cwd)
    if not query or query == "" then
        vim.notify("Please provide a note title or ID", vim.log.levels.WARN)
        return
    end

    local notes, err = database.search_notes(query)
    if err then
        vim.notify("Error: " .. err, vim.log.levels.ERROR)
        return
    elseif not notes or #notes == 0 then
        -- Note doesn't exist, we need to create it
        local project, branch = git.get_context(use_cwd)

        if not project then
            vim.notify("Not in a Git repository falling back to current directory", vim.log.levels.WARN)
            project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end

        if not branch then
            vim.notify("Unable to determine current Git branch", vim.log.levels.WARN)
            branch = "-"
        end
        return database.create_note(query, project, branch)
    else -- Open the first matching note
        vim.cmd("edit " .. vim.fn.fnameescape(notes[1].path))
    end
end

return M
