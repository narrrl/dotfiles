vim.o.number = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.hlsearch = false
vim.o.signcolumn = 'yes'
vim.o.clipboard = 'unnamedplus'
vim.o.undofile = true
vim.o.undodir = '/home/narl/.cache/nvim-undodir'

vim.g.mapleader = ','

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup()

local add = MiniDeps.add

add({
	source = 'chomosuke/typst-preview.nvim'
})
add({
	source = 'williamboman/mason.nvim'
})

add({
	source =  'stevearc/conform.nvim'
})

add({
	source = 'williamboman/mason-lspconfig.nvim'
})

add({
	source = 'mfussenegger/nvim-lint'
})

add({
	source = 'akinsho/toggleterm.nvim'
})

-- Add to current session (install if absent)
add({
  source = 'neovim/nvim-lspconfig',
  -- Supply dependencies near target plugin
  depends = { 'williamboman/mason.nvim' },
})

add({
  source = 'seblyng/roslyn.nvim',
})

add({
  source = 'tris203/rzls.nvim',
})

add({
  source = 'nvim-treesitter/nvim-treesitter',
  -- Use 'master' while monitoring updates in 'main'
  checkout = 'master',
  monitor = 'main',
  -- Perform action after every checkout
  hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})

add({
    -- Completion framework:
  source = 'hrsh7th/nvim-cmp',

    -- LSP completion source:
  depends = {'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/vim-vsnip',
  },
})

add({ source = "catppuccin/nvim", name = "catppuccin" })

require('mini.files').setup({
  mappings = {
    show_help = 'gh',
  },
})
require('mini.icons').setup({style = 'ascii'})
require('mini.pick').setup({})
require('mini.snippets').setup({})
require('mini.notify').setup({})
require('mini.statusline').setup({})
require('mini.tabline').setup({})
require('mini.git').setup({})
local imap_expr = function(lhs, rhs)
vim.keymap.set('i', lhs, rhs, { expr = true })
end
imap_expr('<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr('<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])
_G.cr_action = function()
-- If there is selected item in popup, accept it with <C-y>
if vim.fn.complete_info()['selected'] ~= -1 then return '\25' end
-- Fall back to plain `<CR>`. You might want to customize this
-- according to other plugins. For example if 'mini.pairs' is set up, replace
-- next line with `return MiniPairs.cr()`
return '\r'
end

vim.keymap.set('i', '<CR>', 'v:lua.cr_action()', { expr = true })
require("toggleterm").setup{
  size = function(term)
    if term.direction == "horizontal" then
      return 30
    elseif term.direction == "vertical" then
      return 69
    end
  end,
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  shade_terminals = true,
  persist_size = true,
  direction = 'float',
  close_on_exit = true,
  shell = vim.o.shell,
}

require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "rust", "toml", "c_sharp" },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting=false,
  },
  ident = { enable = true }, 
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
}
require("mason").setup({
    registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
    },
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})
require("mason-lspconfig").setup()
vim.lsp.config('rust_analyzer', {
  -- Server-specific settings. See `:help lsp-quickstart`
  settings = {
    ['rust-analyzer'] = {},
  },
})

require('roslyn').setup({
    config = {
        -- the rest of your Roslyn configuration
        handlers = require("rzls.roslyn_handlers"),
    },
})

require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = ''})
sign({name = 'DiagnosticSignWarn', text = ''})
sign({name = 'DiagnosticSignHint', text = ''})
sign({name = 'DiagnosticSignInfo', text = ''})
--Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force to select one from the menu
-- shortness: avoid showing extra messages when using completion
-- updatetime: set updatetime for CursorHold
vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess = vim.opt.shortmess + { c = true}
vim.api.nvim_set_option('updatetime', 300) 

-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error 
-- Show inlay_hints more frequently 
vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"

vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', {desc = 'Save file'})
vim.keymap.set('n', '<leader>q', '<cmd>quitall<cr>', {desc = 'Exit vim'})

-- Simplified clipboard mappings
-- vim.keymap.set({'n', 'x', 'o'}, '<leader>y', '"+y', {desc = 'Copy to clipboard'})
-- vim.keymap.set({'n', 'x'}, '<leader>p', '"+p', {desc = 'Paste from clipboard'})

vim.keymap.set('n', '<leader>e', '<cmd>lua MiniFiles.open()<cr>', {desc = 'File explorer'})
vim.keymap.set('n', '<leader><space>', '<cmd>Pick buffers<cr>', {desc = 'Search open files'})
vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', {desc = 'Search all files'})
vim.keymap.set('n', '<leader>fh', '<cmd>Pick help<cr>', {desc = 'Search help tags'})

vim.keymap.set('n', '<leader>h', '<cmd>wincmd h<cr>')
vim.keymap.set('n', '<leader>l', '<cmd>wincmd l<cr>')
vim.keymap.set('n', '<leader>j', '<cmd>wincmd j<cr>')
vim.keymap.set('n', '<leader>k', '<cmd>wincmd k<cr>')

require 'typst-preview'.setup {
  -- Setting this true will enable logging debug information to
  -- `vim.fn.stdpath 'data' .. '/typst-preview/log.txt'`
  debug = false,

  -- Custom format string to open the output link provided with %s
  -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
  open_cmd = nil,

  -- Custom port to open the preview server. Default is random.
  -- Example: port = 8000
  port = 0,

  -- Custom host to bind the preview server to.
  -- Note that '0.0.0.0' is not supported and [won't be](https://github.com/Myriad-Dreamin/tinymist/issues/2105)
  -- Example: host = '192.168.0.10'
  host = '127.0.0.1',

  -- Setting this to 'always' will invert black and white in the preview
  -- Setting this to 'auto' will invert depending if the browser has enable
  -- dark mode
  -- Setting this to '{"rest": "<option>","image": "<option>"}' will apply
  -- your choice of color inversion to images and everything else
  -- separately.
  invert_colors = 'never',

  -- Whether the preview will follow the cursor in the source file
  follow_cursor = true,

  -- Provide the path to binaries for dependencies.
  -- Setting this will skip the download of the binary by the plugin.
  -- Warning: Be aware that your version might be older than the one
  -- required.
  dependencies_bin = {
    ['tinymist'] = '/home/narl/.local/share/nvim/mason/bin/tinymist',
    ['websocat'] = '/usr/bin/websocat'
  },

  -- A list of extra arguments (or nil) to be passed to previewer.
  -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
  extra_args = nil,

  -- This function will be called to determine the root of the typst project
  get_root = function(path_of_main_file)
    local root = os.getenv 'TYPST_ROOT'
    if root then
      return root
    end

    -- Look for a project marker so imports from parent dirs stay inside root
    local main_dir = vim.fs.dirname(vim.fn.fnamemodify(path_of_main_file, ':p'))
    local found = vim.fs.find({ 'typst.toml', '.git' }, { path = main_dir, upward = true })
    if #found > 0 then
      return vim.fs.dirname(found[1])
    end

    return main_dir
  end,

  -- This function will be called to determine the main file of the typst
  -- project.
  get_main_file = function(path_of_buffer)
    return path_of_buffer
  end,
}

-- Rust

local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})
