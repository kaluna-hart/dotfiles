return {
	{ "norcalli/nvim-colorizer.lua" },
	{ "marko-cerovac/material.nvim" },
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000,
	},
	{
		"nvimdev/guard.nvim",
		dependencies = { "nvimdev/guard-collection" },
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{ "nvim-lua/plenary.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "MunifTanjim/prettier.nvim" },
	{ "williamboman/mason.nvim" },
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "williamboman/mason.nvim" },
			{ "neovim/nvim-lspconfig" },
		},
	},
	{
		"nvimdev/lspsaga.nvim",
		dependencies = { "nvim-lspconfig" },
		config = function()
			require("lspsaga").setup({
				lightbulb = {
					enable = false,
					enable_in_insert = true,
					sign = true,
					sign_priority = 40,
					virtual_text = true,
				},
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
	},
	{ "nvim-telescope/telescope.nvim" },
	{ "nvim-telescope/telescope-file-browser.nvim" },
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = { "tami5/sqlite.lua" },
	},
	{ "onsails/lspkind.nvim" },
	{ "nvim-tree/nvim-tree.lua" },
	{ "numToStr/Comment.nvim" },
	{ "windwp/nvim-ts-autotag" },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	{
		"akinsho/toggleterm.nvim",
		version = "*",
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{ "xiyaowong/nvim-transparent" },
	{ "machakann/vim-sandwich" },
	{ "andymass/vim-matchup" },
	{ "liuchengxu/vista.vim" },
	{ "cohama/lexima.vim" },
	{ "tpope/vim-repeat" },
	{ "lewis6991/gitsigns.nvim" },
	{
		"dinhhuy258/git.nvim",
	},
	{
		"hrsh7th/nvim-cmp",
	},
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "L3MON4D3/LuaSnip" },
	{ "saadparwaiz1/cmp_luasnip" },
	{ "ray-x/cmp-treesitter" },
	"rafamadriz/friendly-snippets",
	"j-hui/fidget.nvim",
	{
		"rust-lang/rust.vim",
		ft = { "rust" },
		config = function()
			vim.g.rustfmt_autosave = 1
		end,
	},
	{
		"styled-components/vim-styled-components",
		ft = { "javascript", "javascript.jsx", "javascriptreact", "typescript", "typescript.tsx", "typescriptreact" },
		config = function()
			vim.cmd([[source ~/.config/nvim/dein/plugins/vim-styled-components.plug.vim]])
		end,
	},
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			require("hop").setup({ key = "etovxqpdygfblzhckisuran" })
		end,
	},
	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
}
