# UI Tabs Plan — IDE-style buffer tabline

## Status: COMPLETE

---

## What changed

| File                         | Change                                                  |
|------------------------------|---------------------------------------------------------|
| `lua/plugins/bufferline.lua` | New plugin — IDE-style buffer tab bar                   |
| `lua/config/lazy.lua`        | Registered bufferline plugin                            |
| `lua/config/keymaps.lua`     | Remapped tab keys to buffer navigation, IDE-style close |
| `lua/config/utils.lua`       | Added `close_buffer()` with sidebar/exit awareness      |
| `lua/plugins/neotree.lua`    | Sidebar integration, top-level window config            |
| `lua/config/options.lua`     | Updated `showtabline` comment                           |

---

## Plugin choice

**bufferline.nvim** (`akinsho/bufferline.nvim`) — most popular buffer-tabline plugin, actively maintained, covers all requested UX features with minimal config.

---

## Keymap Summary

| Key                   | Action                                 |
|-----------------------|----------------------------------------|
| `<A-o>`               | Next buffer tab                        |
| `<A-i>`               | Previous buffer tab                    |
| `<A-S-O>`             | Move buffer tab right                  |
| `<A-S-I>`             | Move buffer tab left                   |
| `ZZ`                  | Save and close buffer (exits on last)  |
| `ZX`                  | Close buffer without saving            |
| `<A-0>`               | Toggle neo-tree (unchanged)            |
| `<leader><leader>`    | Telescope buffer picker (unchanged)    |
| Mouse left-click      | Switch to that buffer tab              |
| Mouse middle-click    | Close that buffer tab                  |
| Hover close icon      | Click to close that buffer tab         |

---

## Buffer close behavior

| Scenario                                  | Result                              |
|-------------------------------------------|-------------------------------------|
| Multiple buffers open                     | Closes current tab, switches to previous |
| Last buffer, neo-tree open                | Creates empty buffer, neo-tree stays |
| Last buffer, no sidebar                   | Exits Neovim                        |
| On empty unnamed buffer                   | Exits Neovim                        |

---

## Features delivered

- Top tabline showing open buffers with slant separators
- Current buffer clearly highlighted with indicator icon
- Close button per tab (hover-reveal)
- Modified state indicator (● circle)
- Path disambiguation for duplicate filenames
- LSP diagnostics count per tab
- Mouse support (click to switch, middle-click/close-icon to close)
- Neo-tree sidebar offset (tabs don't overlap file tree)
- Special buffers (quickfix, help, prompt) filtered from tab bar
- Stable close behavior with sidebar awareness
