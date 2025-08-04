---@class JotCommands
local M = {}

local core = require("jot.core")

---Setup user commands
function M.setup()
  -- Create commands
  vim.api.nvim_create_user_command("JotBranch", function()
    core.open_branch_note()
  end, { desc = "Open current branch note with jot" })

  vim.api.nvim_create_user_command("JotOpen", function(opts)
    core.open_note(opts.args)
  end, {
    nargs = 1,
    desc = "Open specific note by title or ID",
    complete = function()
      -- TODO: Could implement completion by querying jot for available notes
      return {}
    end
  })
end

return M
