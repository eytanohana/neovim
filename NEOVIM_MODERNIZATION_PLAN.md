# Neovim configuration modernization plan

**Status:** Plan objectives completed on branch `nvim-0.11-modernization` (native LSP, blink.cmp, treesitter folding, deprecated API fixes, dead file removal). This document remains as the audit and step-by-step reference.

This document is the single source of truth for refactoring this config: audit, problems, target layout, and step-by-step plan. All code changes are made only on branch `neovim-refactor`, with small, reviewable commits.

---

## Git workflow and commit strategy

- **Branch:** All edits happen on `neovim-refactor` (created from `master`). No changes on `master` or other branches.
- **Commit size:** Each commit is small, one logical concern, independently reviewable.
- **Commit message:** Explain purpose and scope, not just file names.
- **Order:** Commits are ordered so the history reads like a migration: bootstrap/organization first, then extraction, then cleanup. No giant “rewrite everything” patch.
- **Verification:** After each step, run `nvim` and sanity-check the area touched (e.g. keymaps, LSP, plugins).

---

## Phase 0: Git safety (done)

- **Current branch:** `neovim-refactor` (created from `master`).
- **Working tree:** Clean at plan creation time.
- No code has been changed yet; this plan is written before any refactor commits.

---

## 1. Current architecture audit

### 1.1 File layout

| Path | Inferred responsibility |
|------|---------------------------|
| `init.lua` | Entry point: leader, 2 keymaps, lazy.nvim bootstrap, **entire** `require('lazy').setup({...})` (plugin list + config), then `require` of `custom.options`, `custom.keymaps`, `custom.commands`, `custom.aucommands`. |
| `lua/custom/options.lua` | Editor options: tabs, numbers, clipboard, folding, mouse, etc. |
| `lua/custom/keymaps.lua` | User keymaps: movement, splits, buffers, search, etc. |
| `lua/custom/commands.lua` | User commands: `CC` (toggle colorcolumn 80), `CP` (copy buffer dir to clipboard). |
| `lua/custom/aucommands.lua` | Autocommands: last position, checktime, BufLeave auto-save, yank highlight, qf keymaps, Python CC. |
| `lua/custom/plugins/init.lua` | Returns `{}`; used by lazy’s `{ import = 'custom.plugins' }`. |
| `lua/custom/plugins/neotree.lua` | neo-tree.nvim spec + setup + keymap `<A-0>`. |
| `lua/custom/plugins/toggleterm.lua` | toggleterm.nvim spec + setup; also defines autocmds and keymaps at module load (before `return`). |
| `lua/kickstart/plugins/debug.lua` | nvim-dap + dap-ui + mason-nvim-dap + dap-go, dap-python, Rust codelldb. |
| `lua/kickstart/plugins/indent_line.lua` | indent-blankline.nvim (ibl) with hooks. |
| `lua/kickstart/plugins/autopairs.lua` | nvim-autopairs + cmp integration. |
| `lua/kickstart/plugins/neo-tree.lua` | neo-tree spec (commented out in init.lua). |
| `lua/kickstart/plugins/gitsigns.lua` | gitsigns with recommended keymaps (commented out in init.lua). |
| `lua/kickstart/plugins/lint.lua` | nvim-lint (commented out in init.lua). |
| `lua/kickstart/health.lua` | Health check (version, git, make, unzip, rg). Not required by init.lua. |
| `.luarc.json` | LuaLS: `diagnostics.globals = ["bufnr"]` (workaround for undefined `bufnr` in gitsigns). |

### 1.2 What lives in `init.lua` (inside `require('lazy').setup(...)`)

- **Leader and two keymaps** (before lazy): `<leader>q` (diagnostics), `<Esc><Esc>` in terminal.
- **Plugin list and inline config:**
  - `vim-sleuth`
  - **gitsigns.nvim** – opts with signs and `on_attach` (uses `bufnr` but it’s not a parameter; see Problems).
  - **which-key.nvim** – event + opts + spec.
  - **telescope.nvim** – event, deps, large `config` (setup, extensions, many keymaps).
  - **lazydev.nvim** – ft = 'lua', opts.
  - **nvim-lspconfig** – deps (mason, mason-lspconfig, mason-tool-installer, fidget, cmp-nvim-lsp), large `config`: LspAttach autocmd (keymaps, document highlight, inlay hints), diagnostic config, capabilities, servers (pyright, rust_analyzer, lua_ls), mason-tool-installer, mason-lspconfig handlers.
  - **conform.nvim** – format_on_save, formatters_by_ft, keymap `<leader>f`.
  - **nvim-cmp** – deps (LuaSnip, cmp_luasnip, cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-nvim-lsp-signature-help), config (snippet, mapping, sources).
  - **gruvbox-material** – colorscheme.
  - **todo-comments.nvim** – opts.
  - **mini.nvim** – ai, surround, statusline.
  - **nvim-treesitter** – opts (ensure_installed, highlight, indent).
  - **undotree** – keymap `<leader>u`.
  - Then `require 'kickstart.plugins.debug'`, `require 'kickstart.plugins.indent_line'`, `require 'kickstart.plugins.autopairs'`, and `{ import = 'custom.plugins' }`.
- **Lazy options:** `ui.icons` based on `vim.g.have_nerd_font`.

After the closing `})`, init.lua does:

- `require 'custom.options'`
- `require 'custom.keymaps'`
- `require 'custom.commands'`
- `require 'custom.aucommands'`

So: **core options, keymaps, commands, and autocmds are already split into `lua/custom/*`**. The main problem is that **init.lua still holds a very large inline plugin block** (telescope, LSP, completion, formatting, UI, treesitter, etc.) and a few keymaps/globals at the top.

### 1.3 Load order

1. init.lua runs: leader, two keymaps, lazy path prepend.
2. `require('lazy').setup({ ... })` runs: lazy loads plugin specs; plugins load on events/cmd/ft.
3. After the setup block: `custom.options` → `custom.keymaps` → `custom.commands` → `custom.aucommands`.

So custom keymaps/options run **after** lazy; any keymap or option set inside a plugin’s `config` runs when that plugin loads (often later). That can cause ordering subtleties (e.g. `completeopt` in options.lua vs in cmp’s config).

### 1.4 Suspicious / redundant / risky spots

- **Gitsigns in init.lua:** `on_attach = function()` with no args but uses `bufnr` in keymap opts. Gitsigns calls `on_attach(bufnr)`, so the param exists but isn’t declared; effectively `buffer = nil` and the workaround is `.luarc.json` adding `bufnr` to globals.
- **Duplicate neo-tree:** kickstart version is commented out; only `custom/plugins/neotree.lua` is active. No runtime duplication, but two definitions to maintain.
- **Keymap overlap:** `custom/keymaps.lua` has `<leader>rn` = “toggle relativenumber”; init.lua LSP block has `<leader>rn` = “LSP rename” (buffer-local). In LSP buffers both exist; buffer-local takes precedence. So in non-LSP buffers `<leader>rn` toggles relativenumber; in LSP buffers it renames. Worth documenting or resolving.
- **completeopt:** Set in both `custom/options.lua` (`menuone,noinsert,noselect`) and in nvim-cmp’s `completion.completeopt` (`menu,menuone,noinsert`). Options are required after lazy, so final value depends on load order of cmp; potential for confusion.
- **BufLeave auto-save** in `custom/aucommands.lua`: saves on leave; strong behavior that some users disable.
- **toggleterm.lua:** Autocmds and keymaps are defined at module load (top-level), then `return { ... }` and `config`. Unusual but functional; could be moved into `config` for clarity.

---

## 2. Problems / stale patterns / gap analysis

### 2.1 Responsibilities mixed into init.lua

- **Core bootstrap:** leader, lazy path – appropriate in init.
- **Keymaps:** Two keymaps in init; many more in plugin configs (telescope, LSP, conform, undotree) and in `custom/keymaps.lua`. So “keymaps” are split across init, custom, and plugin configs.
- **Plugin specs and config:** One large inline table: specs, config functions, and keymaps all in one file. Hard to navigate and review.
- **LSP:** LspAttach callback, diagnostic config, capabilities, server list, mason/mason-lspconfig/mason-tool-installer – all in one block. Fits “plugin config” but is a large single block.
- **Editor options:** Correctly in `custom/options.lua`; only load order vs plugin-set options (e.g. completeopt) is a nuance.

### 2.2 Outdated or fragile patterns

- **Gitsigns `bufnr`:** Not passed as parameter; keymaps end up global; `.luarc.json` hides the diagnostic. Should be `on_attach = function(bufnr)`.
- **Kickstart “optional” plugins:** Some are required (debug, indent_line, autopairs), others commented out (lint, neo-tree, gitsigns). The commented ones are dead code unless re-enabled; the active gitsigns is the one in init.lua.
- **Lazy import style:** Mix of inline specs in init.lua and `require 'kickstart.plugins.xxx'` plus `{ import = 'custom.plugins' }`. Works but inconsistent: kickstart returns a single spec or a table of specs; custom uses one file per plugin (or init.lua returning {}).

### 2.3 What should live where (modern layout)

| Concern | Prefer location | Notes |
|--------|------------------|--------|
| Leader, lazy bootstrap | init.lua | Keep minimal. |
| Editor options | lua/config/options.lua (or keep custom/options.lua) | Already separated. |
| Global keymaps | lua/config/keymaps.lua | Centralize; plugin-specific keymaps can stay in plugin module or a dedicated keymaps section. |
| Autocommands | lua/config/autocmds.lua | Already in custom/aucommands.lua; naming can be normalized. |
| User commands | lua/config/commands.lua (or keep custom/commands.lua) | Already separated. |
| Lazy plugin list | lua/config/lazy.lua or lua/plugins/*.lua | Prefer one entry in init that only `require`s or imports; all specs in lua/plugins/*.lua. |
| LSP setup | lua/plugins/lsp.lua (or lua/config/lsp.lua) | Single place: capabilities, LspAttach, servers, mason. |
| Completion (cmp, luasnip) | lua/plugins/completion.lua | Keep LSP capabilities in LSP module; cmp only in completion. |
| Formatting (conform) | lua/plugins/formatting.lua or inside lsp/editor | Can be its own file or with editor. |
| Telescope | lua/plugins/telescope.lua | Spec + setup + keymaps. |
| Treesitter | lua/plugins/treesitter.lua | Spec + opts. |
| Colorscheme / statusline / etc. | lua/plugins/ui.lua (or colorscheme.lua, statusline in mini) | Group UI-related plugins. |
| Git (gitsigns) | lua/plugins/git.lua | Single gitsigns spec; fix bufnr. |
| File tree (neo-tree) | lua/plugins/neo-tree.lua | One source of truth (custom version); remove or repurpose kickstart one. |
| Debug, indent, autopairs, etc. | lua/plugins/debug.lua, editor.lua, etc. | Keep as separate plugin files. |

### 2.4 Anti-patterns to fix

- Too much logic in init.lua (one giant lazy table).
- Plugin config and keymaps embedded in that table instead of in dedicated modules.
- Gitsigns keymaps using undeclared `bufnr` (and .luarc workaround).
- Keymaps split across init, custom, and multiple plugin configs without a single “keymap index” (at least document or group by file).
- Duplicate plugin definitions (neo-tree in kickstart commented vs custom; gitsigns in init vs kickstart commented).
- Optional kickstart plugins as commented `require` lines instead of a clear “enable/disable” list.

---

## 3. Target architecture

Goal: Keep behavior, improve structure, one clear responsibility per file, and easy-to-follow commit history.

### 3.1 Proposed directory layout

- **init.lua**  
  - Set leader, maplocalleader, `vim.g.have_nerd_font`.  
  - Bootstrap lazy.nvim (path, prepend).  
  - Require config in order: options → keymaps → autocmds → commands (or a single `config/init.lua` that does this).  
  - `require('lazy').setup(plugins_spec)` where `plugins_spec` comes from a single module (e.g. `require 'config.lazy'` or `require 'plugins'`).  
  - No plugin config or keymaps defined inside init.lua beyond the bootstrap.

- **lua/config/options.lua**  
  - All `vim.opt` and related editor options (current custom/options.lua content).  
  - Responsibility: appearance, editing behavior, clipboard, folding, etc.  
  - Keep `completeopt` here only if we explicitly decide to own it and remove the duplicate from cmp (document the choice).

- **lua/config/keymaps.lua**  
  - All global keymaps that are not tied to a single plugin (current custom/keymaps.lua).  
  - Optionally: a few “bootstrap” keymaps (e.g. diagnostic quickfix, terminal escape) can stay in init or move here.  
  - Responsibility: one place to look for global keymaps.

- **lua/config/autocmds.lua**  
  - All autocmds (current custom/aucommands.lua).  
  - Responsibility: BufReadPost, FocusGained/BufEnter, BufLeave, TextYankPost, FileType qf/python, etc.  
  - Naming: can rename file from aucommands → autocmds for consistency.

- **lua/config/commands.lua**  
  - User commands (CC, CP).  
  - Unchanged from current custom/commands.lua.

- **lua/config/lazy.lua**  
  - Returns a single table: merged list of plugin specs.  
  - Does not define config inline; it `require`s or builds a list from:  
    - `plugins/editor.lua` (sleuth, which-key, mini, undotree, conform, etc.)  
    - `plugins/telescope.lua`  
    - `plugins/lsp.lua`  
    - `plugins/completion.lua`  
    - `plugins/treesitter.lua`  
    - `plugins/git.lua` (gitsigns only; fix bufnr)  
    - `plugins/ui.lua` (colorscheme, todo-comments)  
    - `plugins/neo-tree.lua` (one file, from current custom)  
    - `plugins/toggleterm.lua`  
    - `plugins/debug.lua`  
    - `plugins/indent.lua`  
    - `plugins/autopairs.lua`  
    - Optional: lint.lua if re-enabled  
  - And the lazy.nvim `opts` (e.g. ui.icons).  
  - Responsibility: single entry point for “what plugins and with what top-level opts.”

- **lua/plugins/*.lua**  
  - Each file returns a lazy spec (table or array of tables).  
  - Responsibility: one concern per file (e.g. telescope = telescope + extensions + its keymaps).  
  - Config and keymaps for that plugin can live in the same file inside the spec’s `config` or `opts`.

- **lua/utils/**  
  - Only if we introduce shared helpers (e.g. a small LSP keymap helper). Not required for the first refactor passes.

### 3.2 What stays out of each file

- **init.lua:** No plugin specs, no large config blocks, no keymap definitions beyond maybe 1–2 bootstrap keymaps if we keep them there.
- **config/options.lua:** No plugin setup, no keymaps.
- **config/keymaps.lua:** No plugin setup, no autocmds; only keymaps.
- **config/autocmds.lua:** No keymaps (except buffer-local in FileType), no plugin setup.
- **config/lazy.lua:** No editor options, no global keymaps; only building the plugin table and lazy opts.
- **plugins/*.lua:** No global options; plugin-specific keymaps and autocmds inside the spec are fine.

### 3.3 Naming and location of “custom”

- Current: `lua/custom/` for options, keymaps, commands, aucommands, plugins.  
- Target: Can either keep `custom/` and add `config/lazy.lua` + move plugin specs to `plugins/`, or rename `custom` → `config` and keep `plugins` under `lua/`. Plan below uses **lua/config/** for options, keymaps, autocmds, commands, lazy, and **lua/plugins/** for all plugin specs. So we will move from `custom/*` to `config/*` and consolidate plugin specs under `plugins/` (with kickstart plugins either moved into `plugins/` or required from there). This is a deliberate, incremental migration so each commit stays small.

---

## 4. Step-by-step refactor plan

Each step is one (or a few) small commits. Order is chosen so the config keeps working and stays reviewable.

| Step | Goal | Files touched | Why now | Risk | Verify | Proposed commit message |
|------|------|----------------|---------|------|--------|--------------------------|
| **0** | (Done) Create branch | - | - | - | - | - |
| **1** | Fix gitsigns bufnr bug | init.lua, .luarc.json | Fix real bug and remove workaround | Low | Open file, check gitsigns keymaps are buffer-local | fix(gitsigns): declare bufnr in on_attach and remove .luarc workaround |
| **2** | Move bootstrap keymaps to custom keymaps | init.lua, lua/custom/keymaps.lua | Centralize keymaps; reduce init.lua | Low | Check \<leader\>q and terminal Esc | refactor: move diagnostic and terminal keymaps to custom/keymaps.lua |
| **3** | Introduce config/lazy.lua and load from init | init.lua, lua/config/lazy.lua (new) | lazy.lua will only return the same table at first (copy from init) | Low | Full startup, :Lazy | refactor: move lazy plugin table to config/lazy.lua |
| **4** | Extract telescope to plugins/telescope.lua | lua/config/lazy.lua, lua/plugins/telescope.lua (new) | Large block; clear boundary | Low | Telescope pickers and keymaps | refactor(plugins): extract telescope to plugins/telescope.lua |
| **5** | Extract LSP block to plugins/lsp.lua | lua/config/lazy.lua, lua/plugins/lsp.lua (new) | Largest block; clear boundary | Medium | LSP attach, go to def, format | refactor(plugins): extract LSP and mason to plugins/lsp.lua |
| **6** | Extract completion (cmp, luasnip) to plugins/completion.lua | lua/config/lazy.lua, lua/plugins/completion.lua (new) | Clear boundary | Low | Completion and snippets | refactor(plugins): extract nvim-cmp to plugins/completion.lua |
| **7** | Extract conform to plugins/formatting.lua | lua/config/lazy.lua, lua/plugins/formatting.lua (new) | Small, self-contained | Low | Format on save, \<leader\>f | refactor(plugins): extract conform to plugins/formatting.lua |
| **8** | Extract gitsigns to plugins/git.lua | lua/config/lazy.lua, lua/plugins/git.lua (new) | Single plugin; already fixed bufnr in step 1 | Low | Gitsigns keymaps and signs | refactor(plugins): extract gitsigns to plugins/git.lua |
| **9** | Extract UI (colorscheme, todo, mini, undotree) to plugins/ui.lua | lua/config/lazy.lua, lua/plugins/ui.lua (new) | Group UI-related | Low | Colors, statusline, todo, undotree | refactor(plugins): extract UI plugins to plugins/ui.lua |
| **10** | Extract treesitter to plugins/treesitter.lua | lua/config/lazy.lua, lua/plugins/treesitter.lua (new) | Clear boundary | Low | TS highlight and indent | refactor(plugins): extract treesitter to plugins/treesitter.lua |
| **11** | Extract remaining inline plugins (sleuth, which-key, lazydev) to plugins/editor.lua | lua/config/lazy.lua, lua/plugins/editor.lua (new) | Shrink lazy.lua to only imports | Low | Startup, which-key, Lua LSP | refactor(plugins): extract editor plugins to plugins/editor.lua |
| **12** | Move kickstart plugins into plugins/ and use import | lua/config/lazy.lua, lua/plugins/* (move/merge), remove or keep kickstart/ | Single plugins/ tree | Low | Debug, indent, autopairs | refactor(plugins): consolidate kickstart and custom plugins under lua/plugins |
| **13** | Rename custom → config (options, keymaps, commands, autocmds) | init.lua, rename dirs/files | Consistent naming | Low | Full config load | refactor: rename custom to config for options, keymaps, commands, autocmds |
| **14** | Normalize autocmds filename (aucommands → autocmds) | init.lua, lua/config/autocmds.lua | Match common convention | Low | Autocmds run | refactor(config): rename aucommands.lua to autocmds.lua |
| **15** | Remove dead kickstart plugin files or document | kickstart/plugins (neo-tree, gitsigns, lint) | Reduce confusion | Low | No regressions | chore: remove or document commented kickstart plugin duplicates |
| **16** | Resolve or document completeopt / \<leader\>rn overlap | options.lua, keymaps.lua, docs or comments | Clarify intent | Low | Completion and keymaps | docs/config: document completeopt and leader-rn behavior |
| **17** | Final cleanup (comments, duplicate requires, lazy opts) | Various | Polish | Low | Full test | chore: final cleanup and comment pass |

Steps 1–3 are the “safest” and can be done first without moving any plugin spec. Steps 4–12 are extractions that keep behavior identical. Steps 13–17 are naming and cleanup.

---

## 5. Open questions and assumptions

- **completeopt:** Assume we keep it in options.lua and ensure it doesn’t break cmp (e.g. use `menu,menuone,noinsert` if we want cmp’s default, or keep `noselect` and document). Defer a single source of truth to a later commit.
- **\<leader\>rn:** Assume we keep current behavior (buffer-local LSP rename in LSP buffers, global relativenumber toggle elsewhere). Document in keymaps or in this plan; optionally rename one binding in a later pass.
- **BufLeave auto-save:** No change in this refactor; behavior preserved.
- **toggleterm.lua:** Autocmds/keymaps at top-level: leave as-is in first passes; optionally move into config in a later “plugin cleanup” step.
- **kickstart/health.lua:** Not required by init; leave as-is unless we add a `:CheckHealth kickstart` or similar.
- **lazy-lock.json:** Keep in repo (user’s README suggests tracking it).

---

## 6. First three safest refactor commits (proposal)

Before editing, the exact scope of the first three commits is:

### Commit 1: Fix gitsigns on_attach bufnr and remove .luarc workaround

- **Included:**  
  - In `init.lua`, change gitsigns `on_attach = function()` to `on_attach = function(bufnr)` so keymaps use the correct buffer.  
  - In `.luarc.json`, remove `"bufnr"` from `diagnostics.globals` (or remove the globals array if it becomes empty).  
- **Deferred:** Any other gitsigns changes, moving gitsigns to a separate file, or keymap changes.

### Commit 2: Move diagnostic and terminal keymaps from init.lua to custom/keymaps.lua

- **Included:**  
  - Remove from init.lua the two keymaps: `<leader>q` (diagnostic setloclist) and `<Esc><Esc>` in terminal mode.  
  - Add the same two keymaps to `lua/custom/keymaps.lua`.  
- **Deferred:** Moving any other keymaps (e.g. from telescope or LSP), renaming `custom` to `config`, or touching plugin config.

### Commit 3: Move lazy plugin table to config/lazy.lua

- **Included:**  
  - Create `lua/config/lazy.lua` that returns the same table currently passed to `require('lazy').setup(...)` (the full plugin spec + lazy opts).  
  - In init.lua, replace the inline table with e.g. `require('lazy').setup(require 'config.lazy')` (or `require 'custom.lazy'` if we keep the custom name for now).  
- **Deferred:** Splitting that table into multiple plugin files; that happens in later commits (steps 4–12).

After these three commits, the config will:

- Have gitsigns keymaps correctly buffer-local and no bogus global.  
- Have all “bootstrap” keymaps in one place (custom/keymaps.lua).  
- Have a single file (config/lazy.lua) that holds the full plugin list, making the next extractions (telescope, LSP, etc.) straightforward and reviewable.

No other refactors (renaming custom → config, extracting plugins, or changing behavior) are included in these three commits.
