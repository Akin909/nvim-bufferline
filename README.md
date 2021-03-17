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

NOTE: tested with [`kitty`](https://github.com/kovidgoyal/kitty), results may vary depending on your terminal emulator of choice

see: `:h bufferline-styling`

#### LSP error indicators

- This is experimental and only works with nvim's native lsp for now

![Bufferline with error indicator](./screenshots/lsp_error.png)

#### Option to show buffer numbers

![Bufferline with numbers ](./screenshots/bufferline_with_numbers.png "Nvim Bufferline")

#### Buffer pick functionality

![Bufferline Pick](./screenshots/bufferline_pick.gif "Bufferline Pick functionality")

#### Make buffer names unique if there are duplicates

![Deduplicated buffers](./screenshots/duplicate_names.png "deduplicated buffer names")

#### Close icons for closing individual buffers

![close buffer with mouse click](./screenshots/close_button.gif)

#### Re-order current buffer

![move current buffer](./screenshots/re-order.gif "Move current buffer")

This order can be persisted between sessions (enabled by default).

#### Modified symbol

<img src="./screenshots/bufferline_with_modified.png" alt="modified icon" width="350px" />

## Requirements

- Nightly nvim
- A patched font (see [nerd fonts](https://github.com/ryanoasis/nerd-fonts))

## Installation

```lua
-- using packer.nvim
use {'akinsho/nvim-bufferline.lua', requires = 'kyazdani42/nvim-web-devicons'}
```

```vim
Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
" Plug 'ryanoasis/vim-devicons' Icons without colours
Plug 'akinsho/nvim-bufferline.lua'
```

## Why another buffer line plugin?

1. I was looking for an excuse to play with lua and learn to create a plugin with it for Neovim and there was nothing else built in lua when I created this.
2. I wanted to add some tweaks to my buffer line and didn't want to figure out a bunch of `vimscript` in some other plugin.

### Why make it public rather than as part of your `init.vim`?

:shrug: figured someone else might like the aesthetic.

## Caveats 🙏

- This won't appeal to everyone's tastes. This plugin is opinionated about how the tabline
  looks, it's unlikely to please everyone, I don't want to try and support a bunch of different
  appearances.
- I want to prevent this becoming a pain to maintain so I'll be conservative about what I add.

## Usage

See the docs for details `:h nvim-bufferline.lua`

You need to be using `termguicolors` for this plugin to work, as it reads the hex `gui` color values
of various highlight groups.

```vim
set termguicolors
" In your init.{vim/lua}
lua require'bufferline'.setup{}
```

You can close buffers by clicking the close icon or by _right clicking_ the tab anywhere

A few of this plugins commands can be mapped for ease of use.

```vim
" These commands will navigate through buffers in order regardless of which mode you are using
" e.g. if you change the order of buffers :bnext and :bprevious will not respect the custom ordering
nnoremap <silent>[b :BufferLineCycleNext<CR>
nnoremap <silent>b] :BufferLineCyclePrev<CR>

" These commands will move the current buffer backwards or forwards in the bufferline
nnoremap <silent><mymap> :BufferLineMoveNext<CR>
nnoremap <silent><mymap> :BufferLineMovePrev<CR>

" These commands will sort buffers by directory, language, or a custom criteria
nnoremap <silent>be :BufferLineSortByExtension<CR>
nnoremap <silent>bd :BufferLineSortByDirectory<CR>
nnoremap <silent><mymap> :lua require'bufferline'.sort_buffers_by(function (buf_a, buf_b) return buf_a.id < buf_b.id end)<CR>
```

If you manually arrange your buffers using `:BufferLineMove{Prev|Next}` during an nvim session this can be persisted for the session.
This is enabled by default but you need to ensure that your `sessionopts+=globals` otherwise the session file will
not track global variables which is the mechanism used to store your sort order.

## Warning

This plugin relies on some basic highlights being set by your colour scheme
i.e. `Normal`, `String`, `TabLineSel` (`WildMenu` as fallback), `Comment`.
It's unlikely to work with all colour schemes, which is not something I will fix tbh.
You can either try manually overriding the colours or manually creating these highlight groups
before loading this plugin.

If the contrast in your colour scheme isn't very high, think an all black colour scheme, some of the highlights of
this plugin won't really work as intended since it depends on darkening things.

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
    max_prefix_length = 15, -- prefix used when a buffer is deduplicated
    tab_size = 18,
    diagnostics = false | "nvim_lsp"
    diagnostics_indicator = function(count, level)
      return "("..count..")"
    end
    show_buffer_close_icons = true | false,
    show_close_icon = true | false,
    show_tab_indicators = true | false,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
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

### LSP Error indicators

By setting `diagnostics = "nvim_lsp"` you will get an indicator in the bufferline for a given tab if it has any errors
This will allow you to tell at a glance if a particular buffer has errors. Currently only the native neovim lsp is
supported, mainly because it has the easiest API for fetching all errors for all buffers (with an attached lsp client).

In order to customise the appearance of the diagnostic count you can pass a custom function in your setup.

```lua
-- rest of config ...

--- count is an integer representing total count of errors
--- level is a string "error" | "warning"
--- this should return a string
--- Don't get too fancy as this function will be executed a lot
diagnostics_indicator = function(count, level)
  local icon = level:match("error") and " " or ""
  return " " .. icon .. count
end
```

#### Example custom indicator

![custom indicator](./screenshots/custom_lsp_indicator.png)

The highlighting for the filename if there is an error can be changed by replacing the highlights for
`error`, `error_visible`, `error_selected`, `warning`, `warning_visible`, `warning_selected`.

### Regular tab sizes

Generally this plugin enforces a minimum tab size so that the buffer line
appears consistent. Where a tab is smaller than the tab size it is padded.
If it is larger than the tab size it is allowed to grow up to the max name
length specified (+ the other indicators).
If you set `enforce_regular_tabs = true` tabs will be prevented from extending beyond
the tab size and all tabs will be the same length

### Sort by `...`

Bufferline allows you to sort the visible buffers by `extension` or `directory`:

```vim
" Using vim commands
:BufferLineSortByExtension
:BufferLineSortByDirectory
```

```lua
-- Or using lua functions
:lua require'bufferline'.sort_buffers_by('extension')`
:lua require'bufferline'.sort_buffers_by('directory')`
```

For more advanced usage you can provide a custom compare function which will
receive two buffers to compare. You can see what fields are available to use using

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

### Bufferline Pick functionality

Using the `BufferLinePick` command will allow for easy selection of a buffer in view.
Trigger the command, using `:BufferLinePick` or better still map this to a key, e.g.

```vim
nnoremap <silent> gb :BufferLinePick<CR>
```

then pick a buffer by typing the character for that specific
buffer that appears

![Bufferline Pick](./screenshots/bufferline_pick.gif "Bufferline Pick functionality")

### Multi-window mode

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
