# aider.nvim

A Neovim plugin to enhance the Aider experience with Floaterm integration.

## Features

- Interactive chat window with Floaterm integration
- AI inline assistant triggered by Cmd-K (macOS) like Cursor
- Code context awareness with line numbers
- Visual selection support
- Quick command suggestions
- Configurable Floaterm window settings
- Automatic Aider process management

## Installation

Using packer.nvim:

```lua
use {
  'your-username/aider.nvim',
  requires = {
    'voldikss/vim-floaterm'  -- Required dependency (https://github.com/voldikss/vim-floaterm)
  },
  config = function()
    require('aider-nvim').setup({
      -- Configuration options
    })
  end
}
```

Using lazy.nvim:

```lua
{
  "your-username/aider.nvim",
  dependencies = {
    "voldikss/vim-floaterm"  -- Required dependency (https://github.com/voldikss/vim-floaterm)
  },
  config = function()
    require("aider-nvim").setup({
      -- Configuration options
    })
  end,
}
```

## Configuration

```lua
require('aider-nvim').setup({
  auto_start = true,               -- Automatically start Aider when Neovim loads
  prompt = "Send text to Aider:  ",  -- Custom prompt text
  code_context_window = 2,         -- Number of lines above/below cursor to include as context
  quick_commands = {               -- Custom quick commands
    "/explain this",
    "/fix that", 
    "/refactor this",
    "/add comments"
  },
  keybindings = {
    send_code = "<leader>ac",      -- Send current buffer content
    send_selection = "<leader>as", -- Send visual selection
    toggle_chat = "<D-k>",         -- Toggle chat window (Cmd-K on macOS)
    call_aider_plus = "<leader>ap",-- Call Aider Plus functionality
  },
  floaterm_command = "FloatermNew --name=AiderPlus-Chat --wintype=vsplit --width=0.4 aider"
})
```

### Quick Commands
Type `/` in the chat window to trigger quick command completion. Default commands include:
- `/explain this` - Explain the code
- `/fix that` - Fix issues in the code
- `/refactor this` - Refactor the code
- `/add comments` - Add comments to the code

Customize the quick commands list using the `quick_commands` configuration option.

### Window Layout
The chat window:
- Automatically aligns with code indentation
- Maintains a 4-character left margin for visual consistency
- Uses a floating window design that follows cursor movement

The Floaterm window:
- Opens as a vertical split (40% width by default)
- Can be customized via the `floaterm_command` configuration
- Persists between chat sessions

## Keybindings

- `<leader>ac` - Send current buffer content to Aider
- `<leader>as` - Send visual selection to Aider
- `<D-k>` (Cmd-K) - Toggle Aider chat window
- `<leader>ap` - Call Aider Plus functionality

## Aider Plus

The `call_aider_plus` function provides extended Aider capabilities. You can call it via:

1. Default keybinding: `<leader>ap`
2. Vim command with specific action:
```vim
:AiderPlus send_code
:AiderPlus send_selection
:AiderPlus toggle_chat
:AiderPlus call_aider_plus
:AiderPlus start
```
3. Direct Lua call:
```lua
require('aider-nvim').call_aider_plus()
```

To customize the keybinding:
```lua
require('aider-nvim').setup({
  keybindings = {
    call_aider_plus = "<your-preferred-keybinding>"
  }
})
```

## Floaterm Integration

The plugin integrates with vim-floaterm to provide a persistent terminal window for Aider. Key features:

- Dedicated terminal window named "AiderPlus-Chat"
- Configurable window position and size
- Automatic window management
- Persistent terminal session

Customize the Floaterm window using the `floaterm_command` configuration option. Example:

```lua
floaterm_command = "FloatermNew --name=AiderPlus-Chat --wintype=split --height=0.3 --position=bottom aider"
```

This would create a horizontal split at the bottom taking up 30% of the window height.
