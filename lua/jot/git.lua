---@class JotGit
local M = {}

local config = require("jot.config")

-- Debug logging
local function debug_log(msg)
  local opts = config.get()
  if opts.debug then
    print("[jot.git] " .. msg)
  end
end

-- Cache for performance
local git_dir_cache = {}
local branch_cache = {}
local project_cache = {}

-- OS path separator
local sep = package.config:sub(1, 1)

---Find git directory for given path
---@param search_path string|nil Path to search from (defaults to current file dir)
---@return string|nil git_dir Full path to .git directory
function M.find_git_dir(search_path)
    local file_dir = search_path or vim.fn.expand('%:p:h')
    debug_log("Searching for git dir from: " .. (file_dir or "nil"))

    -- Check cache first
    if git_dir_cache[file_dir] then
        debug_log("Found cached git dir: " .. (git_dir_cache[file_dir] or "nil"))
        return git_dir_cache[file_dir]
    end

    local root_dir = file_dir
    local git_dir

    -- Walk up directory tree
    while root_dir do
        local git_path = root_dir .. sep .. '.git'
        debug_log("Checking: " .. git_path)
        local stat = vim.loop.fs_stat(git_path)

        if stat then
            debug_log("Found .git at: " .. git_path .. " (type: " .. stat.type .. ")")
            if stat.type == 'directory' then
                git_dir = git_path
                break
            elseif stat.type == 'file' then
                -- Handle submodules/worktrees
                local file = io.open(git_path)
                if file then
                    local content = file:read()
                    git_dir = content and content:match('gitdir: (.+)$')
                    file:close()
                    debug_log("Git file content points to: " .. (git_dir or "nil"))

                    -- Handle relative paths
                    if git_dir and git_dir:sub(1, 1) ~= sep and not git_dir:match('^%a:.*$') then
                        git_dir = root_dir .. sep .. git_dir
                        debug_log("Resolved relative path to: " .. git_dir)
                    end
                end
                if git_dir then break end
            end
        end

        -- Use Neovim's built-in function for reliable parent directory extraction
        local parent_dir = vim.fn.fnamemodify(root_dir, ':h')
        if parent_dir == root_dir or parent_dir == '.' then
            -- We've reached the filesystem root
            root_dir = nil
        else
            root_dir = parent_dir
        end
        debug_log("Moving up to parent dir: " .. (root_dir or "nil"))
    end

    -- Cache result
    debug_log("Final git dir: " .. (git_dir or "nil"))
    git_dir_cache[file_dir] = git_dir
    return git_dir
end

---Get branch name from git directory
---@param git_dir string Path to .git directory
---@return string|nil branch
function M.get_branch_from_git_dir(git_dir)
    if not git_dir then return nil end

    local head_file = git_dir .. sep .. 'HEAD'
    local file = io.open(head_file)
    if not file then return nil end

    local content = file:read()
    file:close()

    if not content then return nil end

    local branch = content:match('ref: refs/heads/(.+)$')
    return branch or content:sub(1, 6) -- fallback to commit hash
end

---Get project name from git directory
---@param git_dir string Path to .git directory
---@return string|nil project
function M.get_project_from_git_dir(git_dir)
    if not git_dir then
        debug_log("No git_dir provided to get_project_from_git_dir")
        return nil
    end

    debug_log("Getting project from git_dir: " .. git_dir)
    -- Extract project name from parent directory of .git
    local repo_root = git_dir:match('(.*)' .. sep .. '%.git$')
    debug_log("Extracted repo root: " .. (repo_root or "nil"))

    local project = repo_root and vim.fn.fnamemodify(repo_root, ':t')
    debug_log("Final project name: " .. (project or "nil"))

    return project
end

---Get git context for current file or CWD
---@param use_cwd boolean|nil If true, use CWD instead of current file
---@return string|nil project, string|nil branch
function M.get_context(use_cwd)
    local search_path

    if use_cwd then
        search_path = vim.fn.getcwd()
        debug_log("Using CWD: " .. search_path)
    else
        local current_file = vim.api.nvim_buf_get_name(0)
        debug_log("Current file: " .. (current_file or "nil"))

        if current_file == "" or current_file == "[No Name]" then
            search_path = vim.fn.getcwd()
            debug_log("No file, falling back to CWD: " .. search_path)
        else
            search_path = vim.fn.fnamemodify(current_file, ":h")
            debug_log("Using file directory: " .. search_path)
        end
    end

    local git_dir = M.find_git_dir(search_path)
    if not git_dir then
        debug_log("No git directory found")
        return nil, nil
    end

    local project = M.get_project_from_git_dir(git_dir)
    local branch = M.get_branch_from_git_dir(git_dir)

    debug_log("Final result - Project: " .. (project or "nil") .. ", Branch: " .. (branch or "nil"))
    return project, branch
end

---Clear caches (useful for testing)
function M.clear_cache()
    git_dir_cache = {}
    branch_cache = {}
    project_cache = {}
end

return M
