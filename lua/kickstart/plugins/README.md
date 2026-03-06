# Optional Kickstart plugins

These plugin specs are **not** loaded by default (they are commented out in `lua/config/lazy.lua`).

- **gitsigns.lua** – Git signs and keymaps (we use `plugins/git.lua` instead).
- **lint.lua** – nvim-lint.
- **neo-tree.lua** – File tree (we use `plugins/neotree.lua` instead).

To enable one: copy its content into `lua/plugins/` or add `require 'kickstart.plugins.<name>'` to the plugin list in `lua/config/lazy.lua`.
