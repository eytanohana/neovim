# Best Developer Experience Plan

## Mission

Transform this Neovim configuration into an elite development environment for
working in a **very large Python codebase (~15,000 files)** — fast, intelligent,
low-friction, polished, and stable.

This is an optimization and refinement project. The existing config is
fundamentally good. Changes must earn their place.

---

## Current-State Assessment

### Architecture

| Layer | State | Assessment |
|-------|-------|------------|
| Core | Neovim 0.11+ with native `vim.lsp.config`/`vim.lsp.enable` | Excellent — modern API |
| Plugin mgr | lazy.nvim with clean module layout | Good — proper lazy-loading structure |
| File layout | `lua/config/`, `lua/plugins/`, `lua/lsp/`, `after/ftplugin/` | Clean and maintainable |
| LSP | basedpyright + ruff (dual server) | Correct architecture |
| Completion | blink.cmp + LuaSnip + friendly-snippets | Fast, modern choice |
| Formatting | conform.nvim (ruff on save) | Solid pipeline |
| Finder | Telescope + fzf-native + ui-select | Standard, reliable |
| Treesitter | With textobjects (function, class, parameter) | Well configured |
| Git | gitsigns with hunk nav/preview/stage/blame | Good workflow |
| UI | gruvbox-material, mini.statusline, bufferline, fidget, which-key | Cohesive |
| Explorer | neo-tree (sidebar, follow-file) | Functional |
| Terminal | toggleterm (horizontal, Alt-3) | Simple, effective |
| Debug | nvim-dap + dap-ui + dap-python + mason | Working pipeline |
| Test | neotest + neotest-python (pytest) | Good foundation |
| Venv | venv-selector.nvim | Present but unconfigured |
| Editor | vim-sleuth, mini.ai, mini.surround, undotree | Good basics |

### What's Working Well

- Clean separation of concerns across files
- Modern Neovim 0.11 native LSP (no lspconfig dependency)
- basedpyright + ruff dual-server is the correct Python architecture
- blink.cmp is fast and well-configured
- Format-on-save with ruff (organize imports + format) is excellent
- Treesitter textobjects with function/class/parameter motions
- Good keybinding conventions (leader-based, Alt for navigation)
- IDE-style buffer management (ZZ/ZX close, bufferline tabs)
- Python-specific Telescope pickers (grep tests, grep source)
- Neotest with pytest adapter and DAP integration

---

## Major Friction Points and Bottlenecks

### Critical: Performance in 15k-file repo

#### 1. basedpyright `diagnosticMode: 'workspace'` — **SHOWSTOPPER**

This is the single biggest performance problem. With `workspace` mode,
basedpyright will attempt to analyze **all** Python files in the workspace on
startup. In a 15,000-file codebase this means:

- 4–8+ GB of RAM consumption
- CPU pegged for minutes during initial analysis
- Every file save triggers re-analysis of dependents across the workspace
- Editor becomes sluggish or unresponsive during analysis bursts

**Fix:** Switch to `openFilesOnly`. This gives excellent active-file intelligence
(type checking, completions, diagnostics for open files and their direct imports)
without the workspace-wide cost.

**Tradeoff:** Cross-file rename and find-all-references will only cover open
files plus their immediate import graph. In practice this is rarely a problem
because Telescope grep handles workspace-wide search, and renames in a 15k-file
repo should go through careful grep-based review anyway.

#### 2. Telescope has no `file_ignore_patterns`

Every `find_files`, `live_grep`, and `grep_string` call scans the entire working
directory including:

- `__pycache__/`, `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`
- `.venv/`, `venv/`, `.tox/`, `.nox/`
- `node_modules/`, `dist/`, `build/`, `.eggs/`, `*.egg-info/`
- `.git/` internals
- Generated/compiled files (`*.pyc`, `*.pyo`, `*.so`)

In a 15k-file repo, this adds significant scanning time and fills results with
noise.

**Fix:** Add `file_ignore_patterns` covering common Python/monorepo excludes.
Telescope's `find_files` uses `fd` when available (which respects `.gitignore`),
but explicit patterns provide defense in depth and cover `live_grep`.

#### 3. No large-file safeguards

Opening a large generated file (minified JS, big JSON fixture, large CSV,
machine-generated code) will:

- Trigger full treesitter parsing (hangs on 50k+ line files)
- Attach LSP (basedpyright tries to analyze it)
- Activate completion (indexes the buffer)
- Activate indent-blankline (renders indent guides for every line)
- Enable foldexpr (treesitter fold computation)

**Fix:** Add a `BufReadPre` autocmd that detects large files (>1MB or >10k lines)
and disables expensive features: treesitter highlighting, LSP attach,
indent-blankline, foldexpr. Show a notification so the user knows why.

#### 4. neotest `pytest_discover_instances = true`

This runs `pytest --collect-only` to discover parametrized test instances. In a
large test suite, collection alone can take 10–30+ seconds.

**Fix:** Set to `false`. Tests are still discoverable by function name; only
individual parametrize IDs are lost. If needed per-project, override in a local
`.nvim.lua`.

#### 5. Neo-tree in large repos

- `follow_current_file` triggers directory scanning on every buffer switch
- `filtered_items.visible = true` shows all hidden/filtered items

In a huge repo with deep directory trees, this causes perceptible lag on buffer
switches.

**Fix:** Keep `follow_current_file` (it's useful) but add
`use_libuv_file_watcher = false` to prevent filesystem watchers from being set up
on the entire tree. Add `never_show` patterns for `__pycache__`, `.mypy_cache`,
etc.

#### 6. Plugin load timing

- Telescope loads on `VimEnter` (fires immediately on startup)
- blink.cmp loads on `VimEnter` (fires immediately on startup)
- Neo-tree has no lazy trigger
- toggleterm keymaps are defined at module level (requires the module at startup)

**Fix:** Lazy-load Telescope on first keymap use (it already has `keys` defined
in its keymaps; just remove `event = 'VimEnter'`). blink.cmp can move to
`InsertEnter`. Neo-tree already defers via lazy.nvim but the `config` function
runs the full setup — add `cmd` or `keys` trigger. toggleterm keymaps can move
inside the plugin spec.

#### 7. bufferline diagnostics rendering

With `diagnostics = 'nvim_lsp'`, bufferline re-renders the tab bar whenever
diagnostics change. With workspace-mode LSP, diagnostics churn constantly.

**Fix:** After switching to `openFilesOnly`, diagnostic churn drops dramatically.
No further change needed — the bufferline diagnostic indicators are useful.

### High: Python Developer Experience Gaps

#### 8. No diagnostic navigation keymaps

There are no `]d`/`[d` keymaps for jumping between diagnostics. The only option
is `<leader>q` which opens the full loclist. This is high-friction for the most
common diagnostic workflow: "go to the next error."

**Fix:** Add `]d`/`[d` for next/prev diagnostic, `]e`/`[e` for next/prev error
specifically.

#### 9. No DAP session lifecycle management

- DAP UI auto-opens on session start but never auto-closes on session end
- No keymap to terminate a debug session
- No keymap to evaluate expression under cursor
- No keymap to run-to-cursor
- No which-key group for debug keymaps (scattered across `<leader>b/B/du/rt` and
  F-keys)

**Fix:** Add `event_terminated` and `event_exited` listeners to auto-close
DAP UI. Add `<leader>de` for eval, `<leader>dt` for terminate, `<leader>dC` for
run-to-cursor. Register a `[D]ebug` which-key group.

#### 10. `scrolloff = 2` is too low

With only 2 lines of context, the cursor frequently hits the edge of the visible
area, causing jarring full-screen redraws. Most experienced Vim users prefer 8+.

**Fix:** Increase to `8`. This keeps 8 lines of context above/below the cursor
at all times, making scrolling feel much smoother.

#### 11. No `<C-d>`/`<C-u>` centering

Half-page scrolling (`<C-d>`/`<C-u>`) leaves the cursor at unpredictable screen
positions. Adding `zz` keeps the cursor centered, dramatically improving spatial
orientation in large files.

**Fix:** Remap `<C-d>` to `<C-d>zz` and `<C-u>` to `<C-u>zz`.

#### 12. No Telescope resume

After running a Telescope picker and closing it, there's no way to reopen it
with the same query and results. This is frustrating when you accidentally close
a grep result.

**Fix:** Add `<leader>s.` mapped to `builtin.resume`.

### Medium: UX and Cohesion

#### 13. which-key groups are incomplete

- No `[D]ebug` group — debug keymaps are scattered and undiscoverable
- `<leader>n` is registered as "Neotest" but `<leader>nr` doesn't have a group prefix visible
- No group for `[G]it` operations (gitsigns uses `<leader>g*`)

**Fix:** Add which-key specs for Debug, Git groups.

#### 14. `<leader>rn` global/local conflict

`<leader>rn` is globally mapped to toggle relative line numbers, but
buffer-locally mapped to LSP rename in LSP-attached buffers. The global comment
acknowledges this, but it means:

- In non-LSP buffers: toggles relative numbers (expected)
- In LSP buffers: renames symbol (expected, but user might want to toggle numbers)

**Fix:** Move relative-number toggle to `<leader>tn` (under `[T]oggle` group)
to eliminate the conflict. `<leader>rn` becomes exclusively LSP rename.

#### 15. venv-selector has no configuration

`opts = {}` means default search behavior, which in a large monorepo will search
extensively for virtualenvs in parent directories, conda, pyenv, etc.

**Fix:** Keep defaults but this is worth noting. If venv discovery is slow, scope
it with `search_venv_managers = false` and explicit `search` paths.

---

## Performance Strategy for Large Repos

### Design principle

**Fast active-file workflows over full-workspace analysis.**

In a 15k-file Python repo, any feature that scales with workspace size is a
liability. The strategy is:

1. **LSP analyzes only open files** — `openFilesOnly` mode gives excellent
   type checking, hover, completion, and diagnostics for active work without
   workspace-wide cost.

2. **Search is explicit and scoped** — Telescope `live_grep` and `find_files`
   are always available for workspace-wide search, but they use fast tools
   (`rg`, `fd`) that handle large repos well. The key is ignoring noise
   directories.

3. **Heavy features degrade gracefully** — Treesitter, LSP, completion, and
   indent guides are disabled for files above a size threshold. This prevents
   one bad file from killing the entire session.

4. **Lazy-loading is aggressive** — Plugins load only when first needed. Startup
   should feel instant regardless of how many plugins are installed.

5. **Git-awareness is the first filter** — `.gitignore` already excludes most
   noise in a well-maintained repo. Telescope's `fd` backend and rg both respect
   it by default. Explicit ignore patterns are defense in depth.

### Expected impact

| Metric | Before | After |
|--------|--------|-------|
| basedpyright RAM (15k files) | 4–8+ GB (workspace) | ~200–500 MB (open files) |
| LSP startup lag | Minutes of analysis | Seconds per file |
| Telescope find_files | Scans everything | Skips noise dirs |
| Large file open | Hangs possible | Graceful degradation |
| Startup time | ~200ms (estimated) | ~100–150ms (lazy-load fixes) |

---

## Python Tooling Strategy

### LSP architecture (unchanged)

- **basedpyright** for types, hover, completion, definitions, references
- **ruff** for linting diagnostics, code actions (fix, organize imports)
- **conform.nvim** for format-on-save (ruff_organize_imports + ruff_format)

This dual-server approach is correct and performant. No change needed.

### Key tuning

| Setting | Current | Proposed | Rationale |
|---------|---------|----------|-----------|
| `diagnosticMode` | `workspace` | `openFilesOnly` | Critical for large repo perf |
| `typeCheckingMode` | `standard` | `standard` (keep) | Good balance of useful/noisy |
| `autoImportCompletions` | `true` | `true` (keep) | Useful; scoped by openFilesOnly |
| `reportMissingTypeStubs` | default (warn) | `none` | Very noisy for untyped deps |
| format-on-save timeout | 500ms | 1000ms | Safety margin for large files |

### Diagnostic responsibility split

| Concern | Owner | Notes |
|---------|-------|-------|
| Type errors | basedpyright | `standard` mode |
| Unused imports | ruff | basedpyright suppressed |
| Unused variables | ruff | basedpyright suppressed |
| Style/linting | ruff | Comprehensive rule set |
| Formatting | ruff (via conform) | On save |
| Import sorting | ruff (via conform) | On save |
| Hover | basedpyright only | ruff hover disabled |

---

## Testing Strategy

### Current state

Neotest + neotest-python is correctly configured. The keymaps are well-organized
under `<leader>n`. The main issues are:

1. `pytest_discover_instances = true` is expensive in large test suites
2. No failure navigation (jump to next/prev failure)
3. No class-level test running

### Proposed changes

| Change | Impact |
|--------|--------|
| Set `pytest_discover_instances = false` | Eliminates expensive collection |
| Add `<leader>nN` for next failed test position | Low-friction failure navigation |
| Keep existing keymaps unchanged | They're well-designed |

---

## Debugging Strategy

### Current state

nvim-dap + dap-ui + dap-python is correctly set up. Mason manages debugpy.
The main issues are lifecycle management and discoverability.

### Proposed changes

| Change | Impact |
|--------|--------|
| Auto-close DAP UI on session end | Cleaner workflow |
| Add `<leader>de` eval expression | Essential for debugging |
| Add `<leader>dt` terminate session | Clean session management |
| Add `<leader>dC` run-to-cursor | Common debugging action |
| Add which-key `[D]ebug` group | Discoverability |
| Remove Go/Rust DAP deps from default load | Leaner for Python focus |

---

## Navigation Strategy

### Telescope tuning for large repos

| Change | Rationale |
|--------|-----------|
| Add `file_ignore_patterns` | Skip noise directories |
| Add `<leader>s.` resume | Reopen last picker |
| Keep `path_display = 'smart'` | Works reasonably well |
| Keep existing Python-specific pickers | Already well-designed |

### Diagnostic navigation

| Keymap | Action |
|--------|--------|
| `]d` / `[d` | Next/prev diagnostic (any severity) |
| `]e` / `[e` | Next/prev error |

### Buffer navigation (unchanged)

The existing Alt-i/Alt-o buffer cycling and `<leader><leader>` buffer picker
are well-designed. No changes needed.

---

## UI / Ergonomics Strategy

### Changes with clear UX improvement

| Change | Rationale |
|--------|-----------|
| `scrolloff = 8` | Much better spatial context |
| `<C-d>zz` / `<C-u>zz` | Centered half-page scrolling |
| which-key Debug + Git groups | Discoverability |
| `<leader>rn` → `<leader>tn` for rel numbers | Eliminate LSP rename conflict |
| Neo-tree `never_show` patterns | Less noise |

### Intentional non-changes

These are personal keybinding choices that I will **not** change, even though
they deviate from Vim defaults. They are clearly intentional:

- `m` → `o<ESC>` (insert line below)
- `V` → `v$` (select to end of line), `vv` → `V` (visual line)
- `?` → buffer fuzzy find
- `;` ↔ `:` swap
- `` ` `` ↔ `~` swap
- `99` → `$`
- `0` → `^`
- `U` → redo
- `cl` → clear line

These reflect deliberate ergonomic preferences and changing them would break
muscle memory.

---

## Proposed Implementation Phases

### Phase 1 — Large-repo performance safeguards

**What:** Core performance changes that make the config viable in a 15k-file repo.

Changes:
- Switch basedpyright `diagnosticMode` to `openFilesOnly`
- Add `reportMissingTypeStubs = 'none'` to reduce noise
- Add large-file autocmd (disable treesitter, LSP, folds, IBL above 1MB/10k lines)
- Add Telescope `file_ignore_patterns` for Python/monorepo excludes
- Set neotest `pytest_discover_instances = false`
- Add Neo-tree `never_show` patterns for `__pycache__`, caches, etc.
- Disable Neo-tree `use_libuv_file_watcher`

**Why:** Without these, the editor will be unusable in a 15k-file repo. This is
the prerequisite for everything else.

**Risk:** `openFilesOnly` reduces cross-file intelligence. Mitigated by
Telescope grep for workspace-wide search and the fact that basedpyright still
follows imports of open files.

### Phase 2 — Lazy-loading and startup optimization

**What:** Ensure plugins load only when needed.

Changes:
- Remove `event = 'VimEnter'` from Telescope (let `keys` handle lazy-loading)
- Move blink.cmp to `event = 'InsertEnter'`
- Add `cmd = 'Neotree'` lazy trigger for neo-tree
- Move toggleterm keymap definitions inside the plugin spec
- Increase format-on-save `timeout_ms` to 1000ms

**Why:** Faster startup and less memory pressure from idle plugins.

**Risk:** Very low. Lazy-loading is well-supported by all these plugins.

### Phase 3 — Navigation and diagnostic ergonomics

**What:** Make navigating code and diagnostics feel effortless.

Changes:
- Add `]d`/`[d` diagnostic navigation
- Add `]e`/`[e` error-only navigation
- Add `<leader>s.` Telescope resume
- Add `<C-d>zz` / `<C-u>zz` centered scrolling
- Increase `scrolloff` to `8`
- Move relative-number toggle from `<leader>rn` to `<leader>tn`

**Why:** These are the most impactful daily-use improvements. Diagnostic
navigation alone saves dozens of interactions per session.

**Risk:** None. Purely additive keymaps (except the `<leader>rn` move, which
resolves a conflict).

### Phase 4 — Debug workflow polish

**What:** Make the debugging experience feel complete and self-contained.

Changes:
- Auto-close DAP UI on session end (add `event_terminated`/`event_exited`
  listeners)
- Add `<leader>de` eval expression under cursor
- Add `<leader>dt` terminate debug session
- Add `<leader>dC` run-to-cursor
- Add which-key `[D]ebug` group
- Clean up DAP ensure_installed (remove Go/Delve if not needed for Python focus)

**Why:** Debug workflows should feel low-friction and discoverable. The current
setup works but has rough edges around session lifecycle and discoverability.

**Risk:** Low. Additive keymaps and lifecycle hooks.

### Phase 5 — UI cohesion and final polish

**What:** Small refinements that make the overall experience feel premium.

Changes:
- Add which-key `[G]it` group for gitsigns keymaps
- Organize existing which-key specs for consistency
- Add `n`/`N` centering (`nzzzv`/`Nzzzv`) for search result navigation
- Add `J` cursor-hold (`mzJ\`z`) so joining lines doesn't move cursor
- Review and clean up any redundant config

**Why:** These are small touches that compound into a noticeably more polished
experience.

**Risk:** None. All additive or purely cosmetic.

---

## Risk / Tradeoff Analysis

| Risk | Severity | Mitigation |
|------|----------|------------|
| `openFilesOnly` reduces cross-file rename | Medium | Use Telescope grep; rename in large repos needs review anyway |
| `openFilesOnly` misses cross-file type errors | Low | Errors surface when files are opened; CI catches the rest |
| Large-file guard disables useful features | Low | Show notification; user can `:edit` to re-enable |
| `pytest_discover_instances = false` loses parametrize IDs | Low | Override per-project in `.nvim.lua` if needed |
| `scrolloff = 8` changes visual behavior | Low | Strictly better for most users; easy to revert |
| Moving `<leader>rn` to `<leader>tn` | Low | Eliminates a real conflict; muscle memory adjustment |

---

## Rollback Notes

Every change is in a separate commit on the `neovim-best-dev-exp` branch.

To rollback any phase:
```bash
git log --oneline  # find the commit before the phase
git revert <commit>
```

To abort the entire upgrade:
```bash
git checkout master
git branch -D neovim-best-dev-exp
```

No existing plugin configs are deleted — only extended or refined.
No plugins are removed — only tuned or lazy-loaded differently.
New keymaps are additive except `<leader>rn` → `<leader>tn`.

---

## Validation Checklist

### Performance
- [ ] Neovim starts without errors
- [ ] `:checkhealth` passes
- [ ] basedpyright shows `openFilesOnly` in `:LspInfo` / client config
- [ ] Opening a Python file in a large repo attaches LSP within 1–2 seconds
- [ ] Telescope `find_files` excludes `__pycache__`, `.venv`, etc.
- [ ] Telescope `live_grep` excludes noise directories
- [ ] Opening a >1MB file does NOT freeze the editor
- [ ] Opening a >1MB file shows a notification about degraded mode
- [ ] No perceptible lag when switching buffers

### Python Intelligence
- [ ] basedpyright provides type diagnostics for the active file
- [ ] ruff provides lint diagnostics (not hover)
- [ ] Format-on-save works (ruff format + import sort)
- [ ] `<leader>f` manual format works
- [ ] `<leader>ci` organizes imports
- [ ] `gd`, `gr`, `gI` work in Python files
- [ ] Hover shows basedpyright info only
- [ ] Rename (`<leader>rn`) works in LSP buffers
- [ ] Code actions (`<leader>ca`) work
- [ ] Completion provides LSP + path + snippets + buffer sources

### Navigation
- [ ] `]d` / `[d` jump to next/prev diagnostic
- [ ] `]e` / `[e` jump to next/prev error
- [ ] `<leader>s.` resumes last Telescope picker
- [ ] `<C-d>` / `<C-u>` scroll and center
- [ ] `<leader>tn` toggles relative numbers (no conflict with rename)

### Testing
- [ ] `<leader>nr` runs nearest test
- [ ] `<leader>nf` runs test file
- [ ] `<leader>ns` runs test suite
- [ ] `<leader>nl` reruns last test
- [ ] `<leader>nd` debugs nearest test
- [ ] No pytest collection lag on test file open

### Debugging
- [ ] `<leader>b` toggles breakpoint
- [ ] `<leader>B` sets conditional breakpoint
- [ ] `F9` starts/continues debug session
- [ ] DAP UI auto-opens on session start
- [ ] DAP UI auto-closes on session end
- [ ] `<leader>de` evaluates expression under cursor
- [ ] `<leader>dt` terminates debug session
- [ ] `<leader>dC` runs to cursor

### UI
- [ ] which-key shows `[D]ebug` group
- [ ] which-key shows `[G]it` group
- [ ] Neo-tree hides `__pycache__` and cache directories
- [ ] scrolloff feels comfortable (8 lines of context)
- [ ] No visual regressions in bufferline, statusline, or sidebar

---

## Quick Wins

Small changes with disproportionate impact:

1. ✅ `scrolloff = 8` — immediate feel improvement
2. ✅ `<C-d>zz`/`<C-u>zz` — smooth scrolling
3. ✅ `]d`/`[d` diagnostics — daily workflow essential
4. ✅ `<leader>s.` resume — recover closed pickers
5. ✅ `nzzzv`/`Nzzzv` — centered search navigation
6. ✅ Neo-tree `never_show` patterns — cleaner tree

## High Leverage Changes

Changes that fundamentally improve the experience:

1. ✅ basedpyright `openFilesOnly` — transforms large-repo performance
2. ✅ Telescope `file_ignore_patterns` — noise-free search
3. ✅ Large-file safeguards — prevents editor freezes
4. ✅ DAP lifecycle management — complete debug workflow
5. ✅ Lazy-loading optimization — faster startup

## Optional Premium Enhancements

Not in scope for this upgrade, but worth considering later:

1. **trouble.nvim** — Better quickfix/diagnostic list UI (replaces loclist)
2. **Aerial/outline.nvim** — Symbol outline sidebar for navigating large files
3. **harpoon** — Pin and instantly switch between frequently used files
4. **diffview.nvim** — Better git diff/merge experience
5. **nvim-ufo** — Better fold UX with peek-inside preview
6. **Per-project LSP settings** — `.nvim.lua` for per-repo basedpyright overrides

---

## Future Enhancements

Ideas that are good but not essential for this upgrade:

- **Coverage gutter** — Show test coverage inline (coverage.py integration)
- **Task runner** — Makefile/justfile integration for common repo commands
- **AI completion** — Copilot or similar, carefully lazy-loaded
- **Per-project config** — `.nvim.lua` or exrc for repo-specific settings
- **Alternate file switching** — Test ↔ source file toggle (`<leader>ta`)
- **Send-to-REPL** — Send selection to a Python REPL in toggleterm
- **Workspace symbols narrowing** — Scope `<leader>ws` to Python files only
- **Smart test detection** — Automatically run related tests when saving source
- **Session management** — Auto-save/restore buffer layout per project
- **Notification history** — Scrollable notification log for missed messages
- **Smooth scrolling** — `vim.o.smoothscroll = true` (Neovim 0.10+)
- **Telescope frecency** — Rank file picker by frequency of use
