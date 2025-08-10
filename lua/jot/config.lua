---@class JotKeymaps
---@field branch_note string Key to open current branch note

---@class JotOptions
---@field jot_cmd string Path to jot executable (for fallback/compatibility)
---@field db_path string|nil Path to jot database (defaults to ~/.jot/notes.db)
---@field keymaps JotKeymaps Key mappings
---@field debug boolean Enable debug messages

---@type JotOptions
local defaults = {
  jot_cmd = "jot.exe",
  db_path = nil, -- Will default to ~/.jot/notes.db
  keymaps = {
    branch_note = "<leader>j",
  },
  debug = false,
  direct_to_database = true, -- Use database by default
}

---@class JotConfig
local M = {}

---@type JotOptions
M.options = vim.deepcopy(defaults)

---Validate configuration options
---@param opts JotOptions
---@return boolean valid
local function validate_config(opts)
  if opts.jot_cmd and type(opts.jot_cmd) ~= "string" then
    vim.notify("Invalid jot_cmd: expected string, got " .. type(opts.jot_cmd), vim.log.levels.ERROR)
    return false
  end

  if opts.keymaps then
    for key, mapping in pairs(opts.keymaps) do
      if type(mapping) ~= "string" then
        vim.notify("Invalid keymap for " .. key .. ": expected string, got " .. type(mapping), vim.log.levels.ERROR)
        return false
      end
    end
  end

  if opts.debug ~= nil and type(opts.debug) ~= "boolean" then
    vim.notify("Invalid debug: expected boolean", vim.log.levels.ERROR)
    return false
  end

  if opts.db_path and type(opts.db_path) ~= "string" then
    vim.notify("Invalid db_path: expected string", vim.log.levels.ERROR)
    return false
  end

  return true
end

---Setup configuration with user options
---@param opts? JotOptions
function M.setup(opts)
  local user_opts = opts or {}

  if not validate_config(user_opts) then
    vim.notify("jot.nvim: Using default configuration due to validation errors", vim.log.levels.WARN)
    M.options = vim.deepcopy(defaults)
    return
  end

  M.options = vim.tbl_deep_extend("force", defaults, user_opts)
end

---Get current configuration
---@return JotOptions
function M.get()
  return M.options
end

return M
