# jot.nvim

A Neovim plugin for seamless integration with the jot note-taking ecosystem. Works alongside the [JonLD/jot](https://github.com/JonLD/jot) CLI/TUI by directly accessing the same SQLite database.

## Features

- **Branch-based notes**: Automatically create/open notes tied to your current Git branch
- **Project organization**: Notes are organized by Git project and branch
- **File-aware context**: Notes based on current file's Git context, not just working directory
- **Direct database access**: No dependency on jot CLI - works by reading the same SQLite database
- **Flexible API**: Support for both current file and working directory contexts

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "JonLD/jot.nvim" }
```

## Usage

### Default Keymaps
- `<leader>j` - Open the note for the current Git branch (based on current file's context)

### Commands
- `:JotBranch` - Open current branch note (current file context)
- `:JotProject` - Open project-level note
- `:JotOpen <title>` - Open a specific note by title or ID

### Programmatic Usage
```lua
-- Open branch note (current file context)
require("jot").branch_note()

-- Open branch note (working directory context)
require("jot").branch_note({ use_cwd = true })

-- Open project note
require("jot").project_note()

-- Open specific note
require("jot").open_note("my note title")
```

## Configuration

```lua
{
    "JonLD/jot.nvim",
    opts = {
        db_path = nil,  -- Path to jot database (defaults to ~/.jot/notes.db)
    },
    cmd = { -- Add commands for lazy loading
        "JotBranch",
        "JotProject",
        "JotOpen",
    },
    keys = {
        {
            "<leader>jj",
            function ()
                require("jot").branch_note()
            end,
            desc = "Open Branch Note (Current File)",
        },
        {
            "<leader>jJ",
            function ()
                require("jot").branch_note({ use_cwd = true })
            end,
            desc = "Open Branch Note (Working Directory)",
        },
        {
            "<leader>jp",
            function ()
                require("jot").project_note()
            end,
            desc = "Open Project Note",
        },
        {
            "<leader>jP",
            function ()
                require("jot").project_note({use_cwd = true})
            end,
            desc = "Open Project Note",
        },
    },
}
```

## Requirements

- Git (for branch detection and project identification)
- SQLite3 command-line tool (for database operations)
- Optional: [JonLD/jot](https://github.com/JonLD/jot) CLI/TUI for additional note management features

## How it Works

This plugin reads and writes to the same SQLite database (`~/.jot/notes.db`) that the jot CLI uses. This means:

- **Seamless integration**: Notes created in Neovim appear in jot CLI and vice versa
- **No process overhead**: Direct database access is faster than spawning CLI processes
- **Independence**: Works even if jot CLI isn't installed
- **Consistency**: Same data structure and organization as jot

## Context Detection

The plugin intelligently determines Git context:

- **Current file context** (default): Uses the Git repository of the currently open file
- **Working directory context**: Uses the Git repository of Neovim's working directory
- **File-aware**: Different files can be in different Git repositories, and notes will be organized accordingly

This is especially useful in monorepos or when working with multiple projects simultaneously.
