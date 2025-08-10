---@class JotGit
local M = {}

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

    -- Check cache first
    if git_dir_cache[file_dir] then
        return git_dir_cache[file_dir]
    end

    local root_dir = file_dir
    local git_dir

    -- Walk up directory tree
    while root_dir do
        local git_path = root_dir .. sep .. '.git'
        local stat = vim.loop.fs_stat(git_path)

        if stat then
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

                    -- Handle relative paths
                    if git_dir and git_dir:sub(1, 1) ~= sep and not git_dir:match('^%a:.*$') then
                        git_dir = root_dir .. sep .. git_dir
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
    end

    -- Cache result
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
        return nil
    end

    -- Extract project name from parent directory of .git
    local repo_root = git_dir:match('(.*)' .. sep .. '%.git$')
    local project = repo_root and vim.fn.fnamemodify(repo_root, ':t')

    return project
end

---Get git context for current file or CWD
---@param use_cwd boolean|nil If true, use CWD instead of current file
---@return string|nil project, string|nil branch
function M.get_context(use_cwd)
    local search_path

    if use_cwd then
        search_path = vim.fn.getcwd()
    else
        local current_file = vim.api.nvim_buf_get_name(0)

        if current_file == "" or current_file == "[No Name]" then
            search_path = vim.fn.getcwd()
        else
            search_path = vim.fn.fnamemodify(current_file, ":h")
        end
    end

    local git_dir = M.find_git_dir(search_path)
    if not git_dir then
        return nil, nil
    end

    local project = M.get_project_from_git_dir(git_dir)
    local branch = M.get_branch_from_git_dir(git_dir)

    return project, branch
end

---Clear caches (useful for testing)
function M.clear_cache()
    git_dir_cache = {}
    branch_cache = {}
    project_cache = {}
end

return M
