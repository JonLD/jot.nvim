---@class JotKeymaps
local M = {}

local config = require("jot.config")
local core = require("jot.core")

---Setup keymaps
function M.setup()
  local opts = config.get()

  -- Set up default keybinding
  if opts.keymaps.branch_note then
    vim.keymap.set('n', opts.keymaps.branch_note, core.open_branch_note, {
      desc = 'Open current branch note with jot',
      silent = true
    })
  end
end

return M
