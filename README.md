# ghopen.nvim
 
NeoVim Plugin to open current file in the GH UI (github.com or Github Enterprise).

## Installation

LazyVim:

```lua
{
  "amjith/ghopen.nvim",
}
```

## Usage

Open a file in vim then try:

```
:Ghopen
```

or 

<leader>go

Opens the file in github.com (comptaible with Github Enterprise).

If you have any lines highlighted visually they will be highlighted in the GH UI as well.

## Configuration

The default keymap `<leader>go` can be overriden as follows:

```lua
{
  "amjith/ghopen.nvim",
  opts = {
    keymap = '<leader>gh'  -- default is <leader>go
  }
}
