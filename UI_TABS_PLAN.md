# UI Tabs Plan — IDE-style buffer tabline

## Current State

| Component        | Current Setup                              |
|------------------|--------------------------------------------|
| Plugin manager   | lazy.nvim                                  |
| File explorer    | neo-tree.nvim (`<A-0>` to toggle)          |
| Tabline          | Built-in (`showtabline = 2`), no plugin    |
| Bufferline       | **None**                                   |
| Statusline       | mini.statusline                            |
| Colorscheme      | gruvbox-material                           |
| Buffer switching | Telescope buffers (`<leader><leader>`)     |
| Tab nav keymaps  | `<A-i>` / `<A-o>` (Vim tabpages)          |
| Buffer close     | No dedicated keymap                        |

### How files open today
- Neo-tree `open` (mapped to `l`) opens files as **buffers** in the current window.
- There is no visual indicator of which buffers are open beyond the Telescope picker.
- `<A-i>` / `<A-o>` navigate Vim **tabpages**, not buffers — these are unrelated to IDE tabs.

---

## Decision: Plugin choice

### Selected: **bufferline.nvim** (`akinsho/bufferline.nvim`)

**Why:**
1. Most widely used buffer-tabline plugin (10k+ GitHub stars, actively maintained).
2. Built-in support for every requested UX feature:
   - Close button per tab
   - Modified indicator (circle when unsaved)
   - Path disambiguation for duplicate filenames (`duplicates_across_groups`)
   - Mouse click to switch, mouse click close button to delete
   - Offset integration with neo-tree (sidebar awareness)
   - Separator styles, diagnostics, sorting
3. Works with gruvbox-material out of the box (inherits highlight groups).
4. Minimal config surface — one plugin spec file, no custom tabline function needed.
5. No conflict with existing mini.statusline or neo-tree setup.

**Alternatives considered:**
- **barbar.nvim** — good but heavier, less conventional config style, slightly less popular.
- **Custom `tabline` function** — too much effort for feature parity; reinventing the wheel.
- **lualine.nvim tabline** — would require replacing mini.statusline; unnecessary disruption.

---

## Implementation Plan

### Step 1 — Plan file (this file)
- Write `UI_TABS_PLAN.md`.
- Commit: `chore(nvim): add ui tabs plan`

### Step 2 — Add bufferline.nvim plugin
- Create `lua/plugins/bufferline.lua` with the plugin spec.
- Configure:
  - `style_preset` or `separator_style` for clean look
  - `show_close_icon` / `show_buffer_close_icons` enabled
  - `modified_icon` = `●` (circle)
  - `close_icon` = `✕`
  - `diagnostics` = `"nvim_lsp"` for inline error indicators
  - `name_formatter` or built-in path disambiguation (`enforce_regular_tabs = false`)
  - `offsets` for neo-tree sidebar
  - `hover` enabled for close button visibility
  - `sort_by` = `"insert_at_end"` so new buffers appear at the right
- Register in `lua/config/lazy.lua`.
- Commit: `feat(nvim): add ide-style buffer tabline`

### Step 3 — Update keymaps for buffer navigation
- Remap `<A-i>` / `<A-o>` from `gT`/`gt` to `BufferLineCyclePrev` / `BufferLineCycleNext`.
- Remap `<A-S-I>` / `<A-S-O>` from `:tabmove` to `BufferLineMovePrev` / `BufferLineMoveNext`.
- Add `<A-w>` or similar to close current buffer cleanly (`:bdelete` or `mini.bufremove`).
- Commit: `feat(nvim): remap tab keymaps to buffer navigation`

### Step 4 — Integrate neo-tree with buffer tabs
- Ensure neo-tree `open` action opens files as buffers (already the default).
- Add `offsets` config in bufferline so the tabline shifts right when neo-tree is open.
- Verify `follow_current_file` still works (neo-tree highlights the file matching the active buffer).
- Commit: `feat(nvim): integrate file tree with buffer tabs`

### Step 5 — Polish and edge cases
- Update `showtabline` option if needed (bufferline manages this itself with `always`/`auto`).
- Ensure clean behavior when:
  - Last buffer is closed (don't quit Neovim unexpectedly)
  - Splits are used (bufferline stays in the global tabline, not per-split)
  - Special buffers (terminal, neo-tree, undotree) are excluded from tabs
- Test mouse interactions: click tab, click close, hover.
- Commit: `refactor(nvim): polish buffer tab ux`

---

## Keymap Summary (after implementation)

| Key          | Action                          |
|--------------|---------------------------------|
| `<A-o>`      | Next buffer tab                 |
| `<A-i>`      | Previous buffer tab             |
| `<A-S-O>`    | Move buffer tab right           |
| `<A-S-I>`    | Move buffer tab left            |
| `<A-w>`      | Close current buffer            |
| `<A-0>`      | Toggle neo-tree (unchanged)     |
| `<leader><leader>` | Telescope buffer picker (unchanged) |

---

## Risk Assessment

- **Low risk**: bufferline.nvim is a display-only plugin; it doesn't change how buffers work internally.
- **Migration**: The only breaking change is `<A-i>`/`<A-o>` switching from Vim tabpages to buffers. This is the desired behavior.
- **Rollback**: Removing the plugin and reverting keymaps fully restores the previous setup.
