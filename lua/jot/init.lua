local M = {}

function M.setup(opts)
  require("jot.config").setup(opts)
  require("jot.commands").setup()
end

M.open_branch_note = function(use_cwd)
  require("jot.core").open_branch_note(use_cwd)
end

M.open_project_note = function(use_cwd)
  require("jot.core").open_project_note(use_cwd)
end

M.open_note = function(query, use_cwd)
  require("jot.core").open_note(query, use_cwd)
end

-- Aliases for backwards compatibility
M.branch = M.open_branch_note

return M
