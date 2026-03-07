# Python IDE Upgrade Plan

## Current-State Assessment

### Architecture
- Neovim 0.11.x with native `vim.lsp.config` / `vim.lsp.enable`
- lazy.nvim plugin manager
- Clean module layout: `lua/config/` (options, keymaps, autocmds, commands, utils),
  `lua/plugins/` (per-concern specs), `lua/lsp/` (per-server configs)
- blink.cmp for completion, conform.nvim for formatting, treesitter, telescope,
  nvim-dap, gitsigns, neo-tree, toggleterm, which-key, mini.nvim

### Existing Python Support
| Area | Current state | Notes |
|------|--------------|-------|
| Type checking | basedpyright (`basic` mode, `openFilesOnly`) | Minimal settings |
| Linting | ruff LSP (no custom settings) | Hover overlaps with basedpyright |
| Formatting | conform.nvim → ruff_organize_imports + ruff_format | Format-on-save disabled for Python |
| Debugging | nvim-dap-python with hardcoded debugpy path | No test debug configs |
| Testing | None | No test runner integration at all |
| Virtualenv | None | No detection, switching, or awareness |
| ftplugin | colorcolumn=80 via autocmd | No dedicated ftplugin file |
| Text objects | mini.ai (generic) | No Python-specific text objects |
| Treesitter | Parser installed, indent disabled | Indent blacklisted |
| Navigation | Standard LSP via telescope | No Python-specific navigation |
| REPL / run | None | No way to run current file or send to REPL |
| Snippets | LuaSnip loaded, no Python snippets | No friendly-snippets |

---

## Python-Specific Pain Points

1. **No virtualenv awareness** — basedpyright uses whatever Python is on PATH;
   no way to select or auto-detect `.venv`, `uv`, conda, or pyenv interpreters.
2. **Ruff hover overlaps basedpyright** — duplicate hover results clutter the UI.
3. **No test runner** — can't run nearest test, test file, or test suite from the editor.
4. **Hardcoded debugpy path** — breaks if the venv doesn't exist; not auto-installed.
5. **No debug launch configs for tests** — can't debug a single pytest.
6. **Format-on-save disabled for Python** — requires manual `<leader>f` every time.
7. **No Python ftplugin** — all Python-specific settings live in autocmds or are missing.
8. **No Python text objects** — no `af`/`if` (function), `ac`/`ic` (class) treesitter objects.
9. **No way to run current file** — no `<leader>r`-style run command.
10. **Treesitter indent disabled** — using Vim's built-in `autoindent` for Python.
11. **basedpyright diagnostics could be richer** — `basic` mode misses useful type errors;
    `openFilesOnly` may miss cross-file issues in medium codebases.
12. **No debugpy in mason ensure_installed** — user must manually provision it.
13. **No import organization keybinding** — only happens via conform format.
14. **Completion lacks Python tuning** — no lazydev-style Python source priority.

---

## Target IDE Capabilities

### Must-have (this upgrade)
- [ ] Robust basedpyright config with practical type checking and venv detection
- [ ] Ruff LSP properly scoped (disable hover, let basedpyright own it)
- [ ] Clean format-on-save with ruff (organize imports + format)
- [ ] Virtualenv detection and selection (`.venv`, uv, conda, pyenv)
- [ ] pytest integration: run nearest / file / suite / last / debug test
- [ ] Polished nvim-dap-python: auto-detect debugpy, launch configs, test debug
- [ ] Python ftplugin with proper settings
- [ ] Python treesitter text objects (function, class)
- [ ] Run current Python file/module command
- [ ] Import organization command
- [ ] Diagnostic navigation keymaps
- [ ] Inlay hints toggle (useful for return types)

### Nice-to-have (this upgrade if clean)
- [ ] Alternate file switching (test ↔ source)
- [ ] Send selection to REPL/terminal
- [ ] Colorcolumn, listchars, whitespace aids for Python

### Future enhancements (not this upgrade)
- [ ] Per-project LSP settings via `.nvim.lua` or direnv
- [ ] neotest adapter for broader test frameworks
- [ ] AI-assisted refactoring
- [ ] Coverage gutter integration
- [ ] Task runner integration (Makefile, just, etc.)

---

## Plugin / Tooling Decisions

| Need | Decision | Rationale |
|------|----------|-----------|
| Test runner | **neotest + neotest-python** | Best-in-class Neovim test runner; supports pytest, async output, nearest/file/suite/last/debug; actively maintained |
| Virtualenv | **venv-selector.nvim** | Lightweight, finds `.venv`/conda/pyenv/uv envs, updates LSP and DAP; much better than manual detection |
| Python text objects | **nvim-treesitter-textobjects** | Treesitter-powered `af`/`if`/`ac`/`ic` plus movement; standard choice |
| Python snippets | **friendly-snippets** | Large curated snippet collection; LuaSnip already loaded |
| Debugpy install | **mason ensure_installed** | Add `debugpy` to mason-tool-installer; eliminates manual venv setup |
| DAP configs | Improve existing nvim-dap-python | Add test debug, current file, module launch configs |
| Format-on-save | Enable in conform for Python | Ruff is fast enough; use ruff_organize_imports + ruff_format |
| Ruff LSP | Disable hover capability | Avoid duplicating basedpyright hover |
| basedpyright | Tune settings | `standard` type checking, workspace diagnostics, venv path |

### Plugins NOT added (and why)
- **black/isort** — ruff handles both; adding them creates overlapping formatters
- **pylsp** — basedpyright + ruff covers all needs; pylsp would be redundant
- **nvim-lint** — ruff LSP provides linting; conform handles formatting; nvim-lint unnecessary
- **overseer.nvim** — overkill for current needs; toggleterm + custom commands suffice

---

## Implementation Phases

### Phase 0 — Plan ✓
Create this plan and the feature branch.

### Phase 1 — Python Architecture Cleanup
- Create `after/ftplugin/python.lua` for Python-specific settings
- Move colorcolumn autocmd into ftplugin
- Add Python-specific options (textwidth, formatoptions, etc.)
- Add which-key group for Python commands
- **Why:** Clean separation makes Python config discoverable and maintainable

### Phase 2 — LSP / Diagnostics / Formatting
- Tune basedpyright: `standard` type checking, `workspace` diagnostics, venv path detection
- Disable ruff hover to avoid basedpyright overlap
- Enable format-on-save for Python via conform (ruff is fast)
- Add `<leader>ci` keymap for import organization
- Add `debugpy` to mason ensure_installed
- **Why:** This is the core language experience; must be right before anything else

### Phase 3 — Testing and Debugging
- Add neotest + neotest-python for pytest
- Configure keymaps: run nearest, file, suite, last, output, debug
- Improve nvim-dap-python: auto-detect debugpy via mason, add test debug config
- Add launch configurations for current file and module
- **Why:** Testing and debugging are the #1 gap vs a real IDE

### Phase 4 — Navigation and Editing Ergonomics
- Add nvim-treesitter-textobjects for Python function/class text objects and movements
- Add friendly-snippets for Python snippet library
- Add venv-selector.nvim for virtualenv switching
- Add alternate file helper (test ↔ source) if clean to implement
- Tune telescope for Python workflows (grep in tests, grep in source)
- **Why:** Navigation speed directly impacts productivity in large codebases

### Phase 5 — Workflow and Task Polish
- Add run-current-file command
- Add send-to-terminal/REPL helper
- Add diagnostic navigation keymaps (`]d`, `[d`, `]e`, `[e`)
- Add Python-specific which-key entries
- Normalize all Python keymaps under consistent prefixes
- **Why:** Small workflow improvements compound into significant daily time savings

### Phase 6 — Final Cleanup
- Remove dead code and unnecessary comments
- Verify no duplicate keymaps or plugin responsibilities
- Test all Python workflows end-to-end
- Document non-obvious choices with comments
- Add Future Enhancements section
- **Why:** Polish and maintainability

---

## Risks and Tradeoffs

| Risk | Mitigation |
|------|-----------|
| neotest adds complexity | Only configure pytest adapter; keep config minimal |
| venv-selector may not find all envs | Falls back to manual path input; configurable search paths |
| `standard` type checking may be noisy | Can dial back to `basic` per-project via pyrightconfig.json |
| Format-on-save may surprise user | Ruff is fast (<50ms); can disable per-project with conform |
| treesitter-textobjects adds load time | Lazy-load on first Python buffer |
| Changing debug adapter path | Mason-managed debugpy is more reliable than manual venv |

---

## Rollback Notes

Every change is in a separate commit on the `neovim-python-ide` branch.
To rollback any phase:
```bash
git log --oneline  # find the commit before the phase
git revert <commit>  # or git reset --soft <commit> for squash
```

The `master` branch is untouched. To abort the entire upgrade:
```bash
git checkout master
git branch -D neovim-python-ide
```

No existing plugin configs are deleted — only extended or refined.
New plugins are additive and can be removed by deleting their spec file.

---

## Validation Checklist

- [ ] Neovim starts without errors
- [ ] `:checkhealth` passes
- [ ] basedpyright attaches to Python files with correct venv
- [ ] ruff provides diagnostics (not hover)
- [ ] Format-on-save works for Python (ruff format + import sort)
- [ ] `<leader>f` manual format works
- [ ] `<leader>ci` organizes imports
- [ ] `gd`, `gr`, `gI` work in Python files
- [ ] `<leader>ds` shows document symbols
- [ ] `<leader>ws` shows workspace symbols
- [ ] Hover shows basedpyright info (not ruff)
- [ ] Rename (`<leader>rn`) works
- [ ] Code actions (`<leader>ca`) work
- [ ] Inlay hints toggle (`<leader>th`) works
- [ ] neotest runs nearest test
- [ ] neotest runs test file
- [ ] neotest runs test suite
- [ ] neotest reruns last test
- [ ] neotest shows test output
- [ ] DAP starts debugging current file
- [ ] DAP debugs current test
- [ ] Breakpoints (regular and conditional) work
- [ ] DAP UI opens/closes properly
- [ ] venv-selector finds and switches virtualenvs
- [ ] Python text objects (`af`, `if`, `ac`, `ic`) work
- [ ] Python motions (`]m`, `[m`, `]M`, `[M`) work
- [ ] Completion provides LSP, path, snippets, buffer sources
- [ ] Python snippets are available
- [ ] Diagnostic navigation (`]d`, `[d`) works
- [ ] Run current Python file works
- [ ] ftplugin settings apply (colorcolumn, textwidth, etc.)
- [ ] No startup performance regression
- [ ] Lua/Rust/general editing still works correctly
