---@class JotCore
local M = {}

local config = require("jot.config")

---Debug logging function
---@param msg string
local function debug_log(msg)
  local opts = config.get()
  if opts.debug then
    print("[jot.nvim] " .. msg)
  end
end

---Check if jot is available
---@return boolean
function M.check_jot_available()
  local opts = config.get()
  local handle = io.popen(opts.jot_cmd .. " 2>&1")
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return not result:match("not found") and not result:match("not recognized")
end

---Execute jot command and return result
---@param args string Command arguments
---@return string|nil file_path
function M.execute_jot(args)
  local opts = config.get()

  -- Add -fromnvim flag so jot knows it's being called from Neovim
  local cmd = opts.jot_cmd .. " " .. args .. " -fromnvim"
  debug_log("Executing: " .. cmd)

  local file_path = vim.fn.system(cmd):gsub("\n", "")

  if vim.v.shell_error ~= 0 then
    vim.notify("Error executing jot: " .. file_path, vim.log.levels.ERROR)
    return nil
  end

  debug_log("Got file path: " .. file_path)
  return file_path
end

---Open branch note
function M.open_branch_note()
  local file_path = M.execute_jot("-branch")
  if file_path then
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    debug_log("Opened file: " .. file_path)
  end
end

---Open specific note by title or ID
---@param query string Note title or ID
function M.open_note(query)
  if not query or query == "" then
    vim.notify("Please provide a note title or ID", vim.log.levels.WARN)
    return
  end

  local file_path = M.execute_jot("-open '" .. query .. "'")
  if file_path then
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    debug_log("Opened file: " .. file_path)
  end
end

return M
