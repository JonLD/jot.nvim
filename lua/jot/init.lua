local M = {}

function M.setup(opts)
  require("jot.config").setup(opts)
  require("jot.commands").setup()
end

M.branch_note = function(opts)
  require("jot.core").branch_note(opts)
end

M.project_note = function(opts)
  require("jot.core").project_note(opts)
end

M.open_note = function(query, opts)
  require("jot.core").open_note(query, opts)
end

-- Aliases for backwards compatibility
M.branch = M.branch_note

return M
