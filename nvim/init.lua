-- ============================================================================
-- === NEOVIM CONFIGURATION ===================================================
-- ============================================================================

-- ============================================================================
-- 1. CORE SETTINGS
-- ============================================================================
vim.g.mapleader = "," -- Set leader key to comma

vim.o.number = true -- Show absolute line numbers
vim.o.wrap = false -- Disable line wrapping globally
vim.o.tabstop = 4 -- Width of a raw <Tab> character
vim.o.shiftwidth = 4 -- Number of spaces used for autoindent
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.smartcase = true -- Override ignorecase if search contains uppercase
vim.o.ignorecase = true -- Case-insensitive searching
vim.o.hlsearch = false -- Disable persistent search highlighting
vim.o.signcolumn = "yes" -- Always show the sign column (prevents text shifting)
vim.o.clipboard = "unnamedplus" -- Sync Neovim with the system clipboard
vim.o.undofile = true -- Enable persistent undo history between sessions
vim.o.undodir = vim.fn.expand("~/.cache/nvim-undodir") -- Path to store undo history

-- ============================================================================
-- 2. PLUGIN MANAGER (mini.deps)
-- ============================================================================
require("mini.deps").setup()
local add = MiniDeps.add

-- UI & Theming
add({ source = "catppuccin/nvim", name = "catppuccin" })
add({ source = "nvim-lualine/lualine.nvim" })
add({ source = "lewis6991/gitsigns.nvim" })
add({ source = "folke/which-key.nvim" })

-- Utility & Editing
add({ source = "akinsho/toggleterm.nvim" })
add({ source = "chomosuke/typst-preview.nvim" })
add({
	source = "MeanderingProgrammer/render-markdown.nvim",
	depends = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
})

-- LSP, Formatting & Linting
add({ source = "williamboman/mason.nvim" })
add({ source = "williamboman/mason-lspconfig.nvim" })
add({ source = "neovim/nvim-lspconfig", depends = { "williamboman/mason.nvim" } })
add({ source = "stevearc/conform.nvim" })
add({ source = "mfussenegger/nvim-lint" })
add({ source = "seblyng/roslyn.nvim" })
add({ source = "tris203/rzls.nvim" })
add({ source = "https://git.narl.io/nvrl/mould-rs", checkout = "main" })

-- Autocompletion
add({
	source = "Saghen/blink.cmp",
	depends = { "rafamadriz/friendly-snippets" },
	hooks = {
		post_install = function(ctx)
			vim.cmd("!cd " .. ctx.path .. " && cargo build --release")
		end,
		post_checkout = function(ctx)
			vim.cmd("!cd " .. ctx.path .. " && cargo build --release")
		end,
	},
})

-- Treesitter
add({
	source = "nvim-treesitter/nvim-treesitter",
	checkout = "master",
	monitor = "main",
	hooks = {
		post_checkout = function()
			vim.cmd("TSUpdate")
		end,
	},
})

-- ============================================================================
-- 3. MINI MODULES SETUP
-- ============================================================================
require("mini.extra").setup()
require("mini.icons").setup({ style = "ascii" })
require("mini.files").setup({ mappings = { show_help = "gh" } })
require("mini.pick").setup()
require("mini.snippets").setup()
require("mini.notify").setup()
require("mini.tabline").setup()
require("mini.git").setup()
require("mini.indentscope").setup()
require("mini.pairs").setup()
require("mini.surround").setup()

-- ============================================================================
-- 4. UI & THEMING
-- ============================================================================

-- Catppuccin Theme
require("catppuccin").setup({
	flavour = "auto",
	background = { light = "latte", dark = "mocha" },
	transparent_background = false,
	show_end_of_buffer = false,
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		treesitter = true,
		mini = { enabled = true },
	},
})
vim.cmd.colorscheme("catppuccin")

-- Git Signs
require("gitsigns").setup()

-- Which-Key (Keybind discoverability)
require("which-key").setup()

-- Lualine (Statusline)
local function active_lsp()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if next(clients) == nil then
		return "No LSP"
	end
	local client_names = {}
	for _, client in ipairs(clients) do
		table.insert(client_names, client.name)
	end
	return "⚙ " .. table.concat(client_names, ", ")
end

require("lualine").setup({
	options = {
		theme = require("catppuccin.utils.lualine")(),
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff" },
		lualine_c = { { "filename", path = 1 }, "diagnostics" },
		lualine_x = { active_lsp },
		lualine_y = { "encoding", "fileformat", "filetype" },
		lualine_z = { "location", "progress" },
	},
})

-- Render Markdown
require("render-markdown").setup({
	enabled = true,
	anti_conceal = { enabled = true },
	heading = {
		icons = { "1. ", "2. ", "3. ", "4. ", "5. ", "6. " },
		backgrounds = {
			"RenderMarkdownH1Bg",
			"RenderMarkdownH2Bg",
			"RenderMarkdownH3Bg",
			"RenderMarkdownH4Bg",
			"RenderMarkdownH5Bg",
			"RenderMarkdownH6Bg",
		},
	},
})

-- ============================================================================
-- 5. TOOLS & INTEGRATIONS
-- ============================================================================

-- Toggleterm
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
})

-- Typst Preview
require("typst-preview").setup({
	debug = false,
	port = 0,
	host = "127.0.0.1",
	invert_colors = "never",
	follow_cursor = true,
	dependencies_bin = {
		["tinymist"] = "/home/narl/.local/share/nvim/mason/bin/tinymist",
		["websocat"] = "/usr/bin/websocat",
	},
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
})

-- ============================================================================
-- 6. TREESITTER, LSP, & AUTOCOMPLETION
-- ============================================================================

-- Treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "rust", "toml", "c_sharp", "python", "typst", "markdown", "markdown_inline" },
	auto_install = true,
	highlight = { enable = true },
	ident = { enable = true },
	rainbow = { enable = true, extended_mode = true },
})

-- Mason (Package Installer)
require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
})

-- Mason LSPConfig
require("mason-lspconfig").setup({
	ensure_installed = {
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
	},
})

-- Blink.cmp (Autocompletion)
require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
	},
	completion = {
		list = { selection = { preselect = false, auto_insert = true } },
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
	signature = { enabled = true },
})

-- Global LSP Setup (Using Blink capabilities)
local capabilities = require("blink.cmp").get_lsp_capabilities()
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
	"marksman",
}

for _, server in ipairs(servers) do
	vim.lsp.config(server, { capabilities = capabilities })
end

-- Dedicated C# Setup
require("roslyn").setup({
	config = { handlers = require("rzls.roslyn_handlers") },
})

-- ============================================================================
-- 7. DIAGNOSTICS, FORMATTING, & LINTING
-- ============================================================================

-- Diagnostics Configuration
local sign = function(opts)
	vim.fn.sign_define(opts.name, { texthl = opts.name, text = opts.text, numhl = "" })
end
sign({ name = "DiagnosticSignError", text = "" })
sign({ name = "DiagnosticSignWarn", text = "" })
sign({ name = "DiagnosticSignHint", text = "" })
sign({ name = "DiagnosticSignInfo", text = "" })

vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	update_in_insert = true,
	underline = true,
	severity_sort = false,
	float = { border = "rounded", source = "always", header = "", prefix = "" },
})

-- Formatting (Conform)
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
		markdown = { "prettier", "injected" },
	},
	format_on_save = function(bufnr)
		if vim.bo[bufnr].filetype ~= "rust" then
			return
		end
		return { timeout_ms = 3000, lsp_fallback = true }
	end,
})

-- Linting (Nvim-Lint)
require("lint").linters_by_ft = {
	python = { "flake8" },
}

-- ============================================================================
-- 8. AUTOCOMMANDS
-- ============================================================================

-- Show floating diagnostic on cursor hold
vim.cmd([[
    set signcolumn=yes
    autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Trigger linting on file save
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

-- Markdown specific settings
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = true
		vim.keymap.set("n", "j", "gj", { buffer = true, desc = "Move down visual line" })
		vim.keymap.set("n", "k", "gk", { buffer = true, desc = "Move up visual line" })
	end,
})

-- Dynamic LSP Keymaps (Loaded only when LSP attaches to a buffer)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local opts = { buffer = event.buf }
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	end,
})

-- ============================================================================
-- 9. GLOBAL KEYMAPS
-- ============================================================================

-- General Operations
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quitall<cr>", { desc = "Exit Neovim" })

-- Window Navigation
vim.keymap.set("n", "<leader>h", "<cmd>wincmd h<cr>", { desc = "Move to left split" })
vim.keymap.set("n", "<leader>l", "<cmd>wincmd l<cr>", { desc = "Move to right split" })
vim.keymap.set("n", "<leader>j", "<cmd>wincmd j<cr>", { desc = "Move to lower split" })
vim.keymap.set("n", "<leader>k", "<cmd>wincmd k<cr>", { desc = "Move to upper split" })

-- Search & Navigation (Mini Pick & Files)
vim.keymap.set("n", "<leader>e", "<cmd>lua MiniFiles.open()<cr>", { desc = "Open File Explorer" })
vim.keymap.set("n", "<leader><space>", "<cmd>Pick buffers<cr>", { desc = "Search open buffers" })
vim.keymap.set("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "Search all files" })
vim.keymap.set("n", "<leader>fh", "<cmd>Pick help<cr>", { desc = "Search help tags" })

-- Formatting Trigger
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 3000 })
end, { desc = "Format file or range" })

-- Diagnostics Navigation
vim.keymap.set("n", "<leader>fd", "<cmd>Pick diagnostic<cr>", { desc = "Search all diagnostics" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
