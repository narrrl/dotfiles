# My Neovim Configuration

A fast, modern, and highly capable Neovim setup tailored for full-stack and systems development. It uses `mini.deps` for blazingly fast plugin management and heavily leverages the `mini.nvim` ecosystem to keep bloat to an absolute minimum.

## Core Capabilities

* **Modern Autocompletion:** Powered by the Rust-based `blink.cmp` for zero-latency, out-of-the-box completion with built-in snippet support.
* **Intelligent Formatting (`conform.nvim`):** Seamless asynchronous formatting for a massive array of languages. 
  * *Special Rule:* Rust files automatically format on save via `rustfmt`.
* **Real-time Linting (`nvim-lint`):** Automatically lints Python files with `flake8` every time the file is saved.
* **Robust Language Server Protocol (LSP):** Fully automated LSP installation and configuration via `mason.nvim` and `mason-lspconfig`. Includes specialized C# support via Roslyn.
* **Aesthetic & UI:** * Beautiful `Catppuccin` (Mocha/Latte) color scheme.
  * Informative status lines and tab lines via `mini.statusline` and `mini.tabline`.
  * Customized floating diagnostic windows and rounded borders.
* **Typst Integration:** Live Typst previewing with `typst-preview.nvim` and compilation via `tinymist`.
* **Integrated Terminal:** Floating terminal toggle via `toggleterm.nvim`.

---

## Supported Languages & Tools

Through `nvim-treesitter`, `mason`, and our custom handlers, this config provides full highlighting, formatting, and LSP support for:

* **Systems & Backend:** Rust (`rust-analyzer`, `rustfmt`), C/C++ (`clangd`, `clang-format`), Go (`gopls`, `gofmt`)
* **.NET:** C# (`roslyn`, `rzls`, `csharpier`)
* **Scripting & Data:** Python (`pyright`, `isort`, `black`, `flake8`), Lua (`lua_ls`, `stylua`), Bash (`bashls`, `shfmt`)
* **Web Ecosystem:** HTML, CSS, JSON, YAML, JavaScript, TypeScript, React (`prettier`, various LSPs)
* **Other:** Typst (`tinymist`, `typstyle`), Robot Framework (`robotcode`), XML (`xmlformatter`)

---

## Keybindings

**Leader Key:** `,` (Comma)

### General
| Keybind | Action |
| :--- | :--- |
| `<leader>w` | Save current file |
| `<leader>q` | Quit all buffers / Exit Neovim |

### File Exploration & Searching (`mini.pick` & `mini.files`)
| Keybind | Action |
| :--- | :--- |
| `<leader>e` | Open File Explorer (`mini.files`) |
| `<leader><space>` | Search open buffers |
| `<leader>ff` | Search all files in current directory |
| `<leader>fh` | Search Neovim help tags |

### Window Management
| Keybind | Action |
| :--- | :--- |
| `<leader>h` | Move to the left window |
| `<leader>j` | Move to the window below |
| `<leader>k` | Move to the window above |
| `<leader>l` | Move to the right window |

### Code Formatting & LSP
| Keybind | Action |
| :--- | :--- |
| `<leader>f` | Format current file or selected range |
| `<leader>K` | Hover: Show documentation for item under cursor |
| `<leader>gd` | Go to Definition |
| `<leader>gr` | Find all references |
| `<leader>rn` | Rename variable/function across the project |
| `<leader>ca` | View available Code Actions (Quick fixes) |

### Terminal (`toggleterm`)
| Keybind | Action |
| :--- | :--- |
| `<C-\>` | Toggle floating terminal |

### Autocompletion (`blink.cmp`)
| Keybind | Action |
| :--- | :--- |
| `<C-Space>` | Manually trigger autocomplete menu |
| `<C-n>` / `<Tab>` | Select next item in the completion menu |
| `<C-p>` / `<S-Tab>`| Select previous item in the completion menu |
| `<CR>` | Confirm selection |

---

## Core Editor Settings
* **Indentation:** 4 spaces (Tabs are expanded to spaces).
* **Line Numbers:** Enabled.
* **Line Wrapping:** Disabled.
* **Clipboard:** Synced with the system clipboard (`unnamedplus`).
* **Undo History:** Persistent (saved to `~/.cache/nvim-undodir`), meaning you can undo changes even after closing and reopening a file.
