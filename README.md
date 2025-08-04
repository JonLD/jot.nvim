# jot.nvim

A Neovim plugin for seamless integration with the jot note-taking CLI.

## Features

- **Branch-based notes**: Automatically create/open notes tied to your current Git branch
- **Smart detection**: Opens in Neovim buffer when called from within Neovim, opens in default editor otherwise
- **Project organization**: Notes are organized by Git project and branch
- **Configurable**: Customize keymaps, commands, and jot executable path
- **Type-safe**: Full EmmyLua type annotations

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "your-username/jot.nvim",
  config = function()
    require("jot").setup({
      -- Optional configuration
      jot_cmd = "jot.exe",  -- Path to jot executable
      keymaps = {
        branch_note = "<leader>jn",  -- Keymap for opening branch note
      },
      debug = false,  -- Enable debug messages
    })
  end,
}
```

## Usage

### Default Keymaps
- `<leader>jn` - Open the note for the current Git branch (creates if doesn't exist)

### Commands
- `:JotBranch` - Open current branch note
- `:JotOpen <title>` - Open a specific note by title or ID

### Programmatic Usage
```lua
-- Open current branch note
require("jot").open_branch_note()

-- Open specific note
require("jot").open_note("my note title")
```

## Configuration

```lua
require("jot").setup({
  -- Path to jot executable (default: "jot.exe")
  jot_cmd = "jot",
  
  -- Key mappings
  keymaps = {
    branch_note = "<leader>jn",  -- Set to nil to disable
  },
  
  -- Enable debug logging
  debug = false,
})
```

## Requirements

- The `jot` binary must be in your PATH
- Git repository (for branch detection)

## Architecture

The plugin follows modern Neovim plugin conventions:

- `lua/jot/config.lua` - Configuration management with validation
- `lua/jot/core.lua` - Core functionality and jot CLI interaction
- `lua/jot/commands.lua` - User command registration
- `lua/jot/keymaps.lua` - Keymap setup
- `lua/jot/init.lua` - Plugin initialization and public API