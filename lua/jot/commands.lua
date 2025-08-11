---@class JotCommands
local M = {}

local core = require("jot.core")

---Setup user commands
function M.setup()
  -- Create commands
  vim.api.nvim_create_user_command("JotBranch", function()
    core.branch_note()
  end, { desc = "Open current branch note" })

  vim.api.nvim_create_user_command("JotProject", function()
    core.project_note()
  end, { desc = "Open project-level note" })

  vim.api.nvim_create_user_command("JotOpen", function(opts)
    core.open_note(opts.args)
  end, {
    nargs = 1,
    desc = "Open specific note by title or ID",
    complete = function()
      -- TODO: Could implement completion by querying database for available notes
      return {}
    end
  })
end

return M
