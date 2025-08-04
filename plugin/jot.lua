-- jot.nvim plugin entry point
-- This file is automatically loaded by Neovim

-- Prevent loading twice
if vim.g.loaded_jot then
  return
end
vim.g.loaded_jot = 1

-- The actual plugin logic is in lua/jot/init.lua
-- Users will call require("jot").setup() in their config