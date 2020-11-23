# nvim-bufferline.lua

A _snazzy_ 💅 buffer line (with minimal tab integration) for Neovim built using **lua**.

![Bufferline](./screenshots/bufferline.png "Bufferline")

This plugin shamelessly attempts to emulate the aesthetics of GUI text editors/Doom Emacs.
It was inspired by a screenshot of DOOM Emacs using [centaur tabs](https://github.com/ema2159/centaur-tabs). I don't intend to copy
all of it's functionality though.

## Features

- Colours derived from colorscheme where possible, should appear similar in most cases

- Sort buffers by `extension`, `directory` or pass in a custom compare function

#### Alternate option for tab styling

![slanted tabs](./screenshots/diagonal.png "slanted tabs")

#### Option to show buffer numbers

![Bufferline with numbers ](./screenshots/bufferline_with_numbers.png "Nvim Bufferline")

#### Buffer pick functionality

![Bufferline Pick](./screenshots/bufferline_pick.gif "Bufferline Pick functionality")

#### Make buffer names unique if there are duplicates

![Deduplicated buffers](./screenshots/duplicate_names.png "deduplicated buffer names")

#### Close icons for closing individual buffers

![close buffer with mouse click](./screenshots/close_button.gif)

#### Modified symbol

<img src="./screenshots/bufferline_with_modified.png" alt="modified icon" width="350px" />

## Requirements

- Nightly nvim
- A patched font (see [nerd fonts](https://github.com/ryanoasis/nerd-fonts))

## Installation

Super early days there might be some breaking changes, if you use this
without configuring it this shouldn't affect you too much.

```vim
Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
" Plug 'ryanoasis/vim-devicons' Icons without colours
Plug 'akinsho/nvim-bufferline.lua'
```

If using native packages make sure to add this plugins in the `/pack/*/opt`
directory. This is because plugins in the `/start` directory are not loaded until
after your `init.vim` is processed which will be too late.

```vim
packadd! nvim-bufferline.lua
" then call setup sometime after this
```

## Usage

You need to be using `termguicolors` for this plugin to work, as it reads the hex `gui` color values
of various highlight groups.

```vim
set termguicolors
" In your init.vim AFTER loading plugins
lua require'bufferline'.setup()
```

You can close buffers by clicking the close icon or by _right clicking_ the tab anywhere

## Warning

This plugin relies on some basic highlights being set by your colour scheme
i.e. `Normal`, `String`, `TabLineSel` (`WildMenu` as fallback), `Comment`.
It's unlikely to work with all colour schemes, which is not something I will fix tbh.
You can either try manually overriding the colours or manually creating these highlight groups
before loading this plugin.

If the contrast in your colour scheme is too high, think an all black colour scheme, this
plugin won't create a nice tabline.

## Why another buffer line plugin?

1. I was looking for an excuse to play with **lua** and learn to create a plugin with it for Neovim.
2. I wanted to add some tweaks to my buffer line and didn't want to figure out a bunch of `vimscript` in some other plugin.

### Why make it public rather than as part of your `init.vim`?

🤷 figured someone else might like the aesthetic. Don't make me regret this...

## Goals

- [x] Make it snazzy
- [x] Maintain general appearance across various colour schemes

### Future Goals

- [x] Show only the buffers relevant/open in a specific tab as a configurable setting
- [ ] Show LSP diagnostics in bufferline so it's clear which buffers have errors

## Non-goals 🙏

- Appeal to every single person's tastes. This plugin is opinionated about how the tabline
  looks, it's unlikely to please everyone, I don't want to try and support a bunch of different
  appearances.
- Supporting vim please don't ask. The whole point was to create a lua plugin. If vim ends up supporting lua in the _same_ way then maybe.
- Add every possible feature under the sun ☀, to appease everybody.
- Create and maintain a monolith 😓.

## Todo

- [ ] Write nvim help docs

## Configuration

```lua
require'bufferline'.setup{
  options = {
    view = "multiwindow" | "default",
    numbers = "none" | "ordinal" | "buffer_id",
    number_style = "superscript" | "",
    mappings = true | false,
    buffer_close_icon= '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 18,
    tab_size = 18,
    show_buffer_close_icons = true | false,
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "slant" | "thick" | "thin" | { 'any', 'any' },
    enforce_regular_tabs = false | true,
    always_show_bufferline = true | false,
    sort_by = 'extension' | 'relative_directory' | 'directory' | function(buffer_a, buffer_b)
      -- add custom logic
      return buffer_a.modified > buffer_b.modified
    end
  }
}
```

#### NOTE:

If using a plugin such as `vim-rooter` and you want to sort by path, prefer using `directory` rather than
`relative_directory`. Relative directory works by ordering relative paths first, however if you move from
project to project and vim switches its directory, the bufferline will re-order itself as a different set of
buffers will now be relative.

### Regular tab sizes

Generally this plugin enforces a minimum tab size so that the buffer line
appears consistent. Where a tab is smaller than the tab size it is padded.
If it is larger than the tab size it is allowed to grow up to the max name
length specified (+ the other indicators).
If you set `enforce_regular_tabs = true` tabs will be prevented from extending beyond
the tab size and all tabs will be the same length

### Sort by `...`

Bufferline allows you to sort the visible buffers by `extension` or `directory`, or for more
advanced usage you can provide a custom compare function which will receive two buffers to compare.
You can see what fields are available to use using

```lua
sort_by = function(buffer_a, buffer_b)
  print(vim.inspect(buffer_a))
-- add custom logic
  return buffer_a.modified > buffer_b.modified
end
```

When using a sorted bufferline it's advisable that you use the `BufferLineCycleNext` and `BufferLineCyclePrev`
commands since these will traverse the bufferline bufferlist in order whereas `bnext` and `bprev` will cycle
buffers according to the buffer numbers given by vim.

### Bufferline Pick functionality (inspired by [`barbar.nvim`](https://github.com/romgrk/barbar.nvim))

Using the `BufferLinePick` command will allow for easy selection of a buffer in view.
Trigger the command, using `:BufferLinePick` or better still map this to a key, e.g.

```vim
nnoremap <silent> gb :BufferLinePick<CR>
```

then pick a buffer by typing the character for that specific
buffer that appears

![Bufferline Pick](./screenshots/bufferline_pick.gif "Bufferline Pick functionality")

### Multi-window mode (inspired by [`vem-tabline`](https://github.com/pacha/vem-tabline))

When this mode is active, for layouts of multiple windows in the tabpage,
only the buffers that are displayed in those windows are listed in the
tabline. That only applies to multi-window layouts, if there is only one
window in the tabpage, all buffers are listed.

### Mappings

If the `mappings` option is set to `true`. `<leader>`1-9 mappings will
be created to navigate the first to the tenth buffer in the bufferline.
**This is false by default**. If you'd rather map these yourself, use:

```vim
nnoremap mymap :lua require"bufferline".go_to_buffer(num)<CR>
```

### Highlight configuration

This plugin is designed to work automatically, deriving colours from the user's theme,
but if you must...

```vim
lua require'bufferline'.setup{
  highlights = {
    tab = {
      guifg = comment_fg,
      guibg = normal_bg,
    };
    tab_selected = {
      guifg = comment_fg,
      guibg = tabline_sel_bg,
    };
    buffer = {
      guifg = comment_fg,
      guibg = custom_bg,
    };
    buffer_inactive = {
      guifg = comment_fg,
      guibg = normal_bg,
    };
    modified = {
      guifg = diff_add_fg,
      guibg = "none"
    };
    separator = {
      guibg = custom_bg,
    };
    selected = {
      guifg = normal_fg,
      guibg = normal_bg,
      gui = "bold,italic",
    };
  };
}
```
