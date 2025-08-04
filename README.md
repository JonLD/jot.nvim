# jot.nvim

A Neovim plugin for seamless integration with the [JonLD/jot](https://github.com/JonLD/jot), the smart note CLI/TUI.

## Features

- **Branch-based notes**: Automatically create/open notes tied to your current Git branch
- **Project organization**: Notes are organized by Git project and branch
- **Configurable**: Customize keymaps, commands, and jot executable path

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "JonLD/jot.nvim" }
```

## Usage

### Default Keymaps
- `<leader>j` - Open the note for the current Git branch (creates if doesn't exist)

### Commands
- `:JotBranch` - Open current branch note
- `:JotOpen <title>` - Open a specific note by title or ID

### Programmatic Usage
```lua
-- Open current branch note
require("jot").branch()

-- Open specific note
require("jot").open_note("my note title")
```

## Configuration

```lua
{
    "JonLD/jot.nvim",
    opts = {
        -- Optional configuration
        jot_cmd = "jot.exe",  -- Path to jot executable
    }
    keys = {
        "<leader>j",
        function()
            require("jot").branch()
        end,
        desc = "Open branch note"
    },
}
```

## Requirements

- jot binary, either built from source or from releases see [JonLD/jot](https://github.com/JonLD/jot)
- The `jot` binary must be in your PATH if not specified in `jot_cmd` (see configuration)
- Git (for branch detection)

## Architecture

The plugin follows modern Neovim plugin conventions:

- `lua/jot/config.lua` - Configuration management with validation
- `lua/jot/core.lua` - Core functionality and jot CLI interaction
- `lua/jot/commands.lua` - User command registration
- `lua/jot/keymaps.lua` - Keymap setup
- `lua/jot/init.lua` - Plugin initialization and public API
