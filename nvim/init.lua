vim.o.number = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.hlsearch = false
vim.o.signcolumn = "yes"
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.undodir = "/home/narl/.cache/nvim-undodir"

vim.g.mapleader = ","

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup()

local add = MiniDeps.add
add({
	source = "lewis6991/gitsigns.nvim",
})
add({
	source = "chomosuke/typst-preview.nvim",
})
add({
	source = "williamboman/mason.nvim",
})

add({
	source = "stevearc/conform.nvim",
})

add({
	source = "williamboman/mason-lspconfig.nvim",
})

add({
	source = "mfussenegger/nvim-lint",
})

add({
	source = "akinsho/toggleterm.nvim",
})

-- Add to current session (install if absent)
add({
	source = "neovim/nvim-lspconfig",
	-- Supply dependencies near target plugin
	depends = { "williamboman/mason.nvim" },
})

add({
	source = "seblyng/roslyn.nvim",
})

add({
	source = "tris203/rzls.nvim",
})

add({
	source = "nvim-treesitter/nvim-treesitter",
	-- Use 'master' while monitoring updates in 'main'
	checkout = "master",
	monitor = "main",
	-- Perform action after every checkout
	hooks = {
		post_checkout = function()
			vim.cmd("TSUpdate")
		end,
	},
})

add({
	source = "https://git.narl.io/nvrl/mould-rs",
	checkout = "main",
})

add({ source = "catppuccin/nvim", name = "catppuccin" })
add({ source = "folke/which-key.nvim" })
add({
    source = 'Saghen/blink.cmp',
    depends = { 'rafamadriz/friendly-snippets' },
    -- Compile the Rust binary after downloading
    hooks = {
        post_install = function(ctx)
            vim.cmd('!cd ' .. ctx.path .. ' && cargo build --release')
        end,
        post_checkout = function(ctx)
            vim.cmd('!cd ' .. ctx.path .. ' && cargo build --release')
        end
    },
})

require("mini.files").setup({
	mappings = {
		show_help = "gh",
	},
})
require("mini.icons").setup({ style = "ascii" })
require("mini.pick").setup({})
require("mini.snippets").setup({})
require("mini.notify").setup({})
require("mini.statusline").setup({})
require("mini.tabline").setup({})
require("mini.git").setup({})
require("gitsigns").setup()
require("mini.indentscope").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("which-key").setup()
local imap_expr = function(lhs, rhs)
	vim.keymap.set("i", lhs, rhs, { expr = true })
end
imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])
_G.cr_action = function()
	-- If there is selected item in popup, accept it with <C-y>
	if vim.fn.complete_info()["selected"] ~= -1 then
		return "\25"
	end
	-- Fall back to plain `<CR>`. You might want to customize this
	-- according to other plugins. For example if 'mini.pairs' is set up, replace
	-- next line with `return MiniPairs.cr()`
	return "\r"
end

vim.keymap.set("i", "<CR>", "v:lua.cr_action()", { expr = true })
require("toggleterm").setup({
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
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
})

require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "rust", "toml", "c_sharp", "python", "typst" },
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	ident = { enable = true },
	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = nil,
	},
})
require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

local capabilities = require('blink.cmp').get_lsp_capabilities()

require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls", -- Lua
		"gopls", -- Go
		"clangd", -- C/C++
		"html", -- HTML
		"cssls", -- CSS
		"jsonls", -- JSON
		"yamlls", -- YAML
		"bashls", -- Bash/Shell
		"pyright", -- Python
		"ts_ls", -- JS/TS/React
		"rust_analyzer", -- Rust
		"robotcode", -- Robot Framework
		"tinymist", -- Typst
	},
})

-- List out the servers you are using
local servers = {
	"lua_ls",
	"gopls",
	"clangd",
	"html",
	"cssls",
	"jsonls",
	"yamlls",
	"bashls",
	"pyright",
	"ts_ls",
	"rust_analyzer",
	"robotcode",
	"tinymist",
}

-- Configure capabilities for each server using Neovim's native API
for _, server in ipairs(servers) do
	vim.lsp.config(server, {
		capabilities = capabilities,
	})
end

require("roslyn").setup({
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
		numhl = "",
	})
end

sign({ name = "DiagnosticSignError", text = "" })
sign({ name = "DiagnosticSignWarn", text = "" })
sign({ name = "DiagnosticSignHint", text = "" })
sign({ name = "DiagnosticSignInfo", text = "" })

vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option("updatetime", 300)

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
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

vim.cmd.colorscheme("catppuccin")

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quitall<cr>", { desc = "Exit vim" })

vim.keymap.set("n", "<leader>e", "<cmd>lua MiniFiles.open()<cr>", { desc = "File explorer" })
vim.keymap.set("n", "<leader><space>", "<cmd>Pick buffers<cr>", { desc = "Search open files" })
vim.keymap.set("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "Search all files" })
vim.keymap.set("n", "<leader>fh", "<cmd>Pick help<cr>", { desc = "Search help tags" })

vim.keymap.set("n", "<leader>h", "<cmd>wincmd h<cr>")
vim.keymap.set("n", "<leader>l", "<cmd>wincmd l<cr>")
vim.keymap.set("n", "<leader>j", "<cmd>wincmd j<cr>")
vim.keymap.set("n", "<leader>k", "<cmd>wincmd k<cr>")

require("typst-preview").setup({
	debug = false,
	open_cmd = nil,
	port = 0,
	host = "127.0.0.1",
	invert_colors = "never",
	follow_cursor = true,
	dependencies_bin = {
		["tinymist"] = "/home/narl/.local/share/nvim/mason/bin/tinymist",
		["websocat"] = "/usr/bin/websocat",
	},
	extra_args = nil,
	get_root = function(path_of_main_file)
		local root = os.getenv("TYPST_ROOT")
		if root then
			return root
		end

		local main_dir = vim.fs.dirname(vim.fn.fnamemodify(path_of_main_file, ":p"))
		local found = vim.fs.find({ "typst.toml", ".git" }, { path = main_dir, upward = true })
		if #found > 0 then
			return vim.fs.dirname(found[1])
		end

		return main_dir
	end,
	get_main_file = function(path_of_buffer)
		return path_of_buffer
	end,
})

require('blink.cmp').setup({
    -- 'default' maps match standard nvim-cmp behavior (<C-space>, <C-n>, <C-p>, <CR>)
    -- 'super-tab' uses your Tab key for everything
    keymap = { preset = 'default' },

    appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        nerd_font_variant = 'mono'
    },

    -- Default list of enabled providers
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- Enable displaying function signatures as you type parameters
    signature = { enabled = true }
})

require("conform").setup({
	formatters_by_ft = {
		cs = { "csharpier" },
		rust = { "rustfmt" },
		lua = { "stylua" },
		go = { "gofmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		python = { "isort", "black" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		typst = { "typstyle" },
		xml = { "xmlformatter" },
	},

	format_on_save = function(bufnr)
		if vim.bo[bufnr].filetype ~= "rust" then
			return
		end

		return {
			timeout_ms = 3000,
			lsp_fallback = true,
		}
	end,
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 3000,
	})
end, { desc = "Format file or range" })

-- Nvim-Lint Configuration
require("lint").linters_by_ft = {
	python = { "flake8" },
}

-- Trigger linting on file save
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = { buffer = event.buf }
    
    -- Press 'K' to show hover documentation
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    -- Press 'gd' to jump to a function/variable definition
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    -- Press '<leader>rn' to rename a variable across the whole project
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    -- Press '<leader>ca' to see code actions (like quick fixes)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    -- Press 'gr' to find all references of the word under your cursor
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})
