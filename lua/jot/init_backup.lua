-- Backup of working version
local M = {}

-- Default configuration
local config = {
  jot_cmd = "jot.exe",
  keymap = "<leader>jn",
  debug = false,
}

-- Debug logging function
local function debug_log(msg)
  if config.debug then
    print("[jot.nvim] " .. msg)
  end
end

-- Check if jot is available
local function check_jot_available()
  local handle = io.popen(config.jot_cmd .. " 2>&1")
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return not result:match("not found") and not result:match("not recognized")
end

-- Execute jot command and return result
local function execute_jot(args)
  local cmd = config.jot_cmd .. " " .. args .. " -fromnvim"
  debug_log("Executing: " .. cmd)

  local file_path = vim.fn.system(cmd):gsub("\n", "")

  if vim.v.shell_error ~= 0 then
    vim.notify("Error executing jot: " .. file_path, vim.log.levels.ERROR)
    return nil
  end

  debug_log("Got file path: " .. file_path)
  return file_path
end

-- Open branch note
function M.open_branch_note()
  local file_path = execute_jot("-branch")
  if file_path then
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    debug_log("Opened file: " .. file_path)
  end
end

-- Open specific note by title or ID
function M.open_note(query)
  if not query or query == "" then
    vim.notify("Please provide a note title or ID", vim.log.levels.WARN)
    return
  end

  local file_path = execute_jot("-open '" .. query .. "'")
  if file_path then
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    debug_log("Opened file: " .. file_path)
  end
end

-- Setup function
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if not check_jot_available() then
    vim.notify("jot.nvim: jot executable not found in PATH. Please ensure jot.exe is installed and accessible.", vim.log.levels.WARN)
    return
  end

  debug_log("jot.nvim initialized successfully")

  vim.api.nvim_create_user_command("JotBranch", function()
    M.open_branch_note()
  end, { desc = "Open current branch note with jot" })

  vim.api.nvim_create_user_command("JotOpen", function(opts)
    M.open_note(opts.args)
  end, {
    nargs = 1,
    desc = "Open specific note by title or ID",
    complete = function()
      return {}
    end
  })

  if config.keymap then
    vim.keymap.set('n', config.keymap, M.open_branch_note, {
      desc = 'Open current branch note with jot',
      silent = true
    })
  end
end

return M