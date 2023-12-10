return {
	{ "NvChad/nvim-colorizer.lua" },
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
	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"b0o/schemastore.nvim",
		config = function()
			local status, lspconfig = pcall(require, "lspconfig")
			if not status then
				return
			end
			lspconfig.jsonls.setup({
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			})
			lspconfig.yamlls.setup({})
			settings = {
				yaml = {
					schemaStore = {
						-- You must disable built-in schemaStore support if you want to use
						-- this plugin and its advanced options like `ignore`.
						enable = false,
						-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
				},
			}
		end,
	},
	{
		"sourcegraph/sg.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("sg").setup({
				-- Pass your own custom attach function
				--    If you do not pass your own attach function, then the following maps are provide:
				--        - gd -> goto definition
				--        - gr -> goto references
				-- on_attach = your_custom_lsp_attach_function,
			})
			-- " Example mapping for doing searches from within neovim (may change) using telescope.
			-- " (requires telescope.nvim to be installed)
			local keymap = vim.keymap.set
			keymap("n", "<leader>ct", "<Cmd>CodyToggle<CR>")
		end,
	},
	{
		"Exafunction/codeium.nvim",
		event = "BufEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({})
		end,
	},
	{
		"kevinhwang91/nvim-hlslens",
		config = function()
			require("hlslens").setup({
				calm_down = true,
				nearest_only = true,
				nearest_float_when = "always",

				override_lens = function(render, posList, nearest, idx, relIdx)
					local sfw = vim.v.searchforward == 1
					local indicator, text, chunks
					local absRelIdx = math.abs(relIdx)
					if absRelIdx > 1 then
						indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and "▲" or "▼")
					elseif absRelIdx == 1 then
						indicator = sfw ~= (relIdx == 1) and "▲" or "▼"
					else
						indicator = ""
					end

					local lnum, col = unpack(posList[idx])
					if nearest then
						local cnt = #posList
						if indicator ~= "" then
							text = ("[%s %d/%d]"):format(indicator, idx, cnt)
						else
							text = ("[%d/%d]"):format(idx, cnt)
						end
						chunks = { { " ", "Ignore" }, { text, "HlSearchLensNear" } }
					else
						text = ("[%s %d]"):format(indicator, idx)
						chunks = { { " ", "Ignore" }, { text, "HlSearchLens" } }
					end
					render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
				end,
			})
			vim.keymap.set({ "n", "x" }, "<Leader>L", function()
				vim.schedule(function()
					if require("hlslens").exportLastSearchToQuickfix() then
						vim.cmd("cw")
					end
				end)
				return ":noh<CR>"
			end, { expr = true })
		end,
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.opt.termguicolors = true
			local notify = require("notify")
			notify.setup()
			vim.notify = notify
			local telescope = require("telescope")
			telescope.load_extension("notify")

			vim.keymap.set("n", "<leader>fn", function()
				telescope.extensions.notify.notify()
			end)
		end,
	},
}
