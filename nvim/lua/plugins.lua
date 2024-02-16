return {
	{ "NvChad/nvim-colorizer.lua" },
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{ "nvim-lua/plenary.nvim" },
	{ "neovim/nvim-lspconfig" },
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
		dependencies = {
			"nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("lspsaga").setup({
				lightbulb = {
					enable = false,
					enable_in_insert = true,
					sign = true,
					sign_priority = 40,
					virtual_text = true,
				},
				code_action = {
					show_server_name = true,
					extend_gitsigns = true,
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
		"mrcjkb/rustaceanvim",
		version = "^4", -- Recommended
		ft = { "rust" },
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-rust"),
					require("neotest-plenary"),
					require("neotest-vim-test")({ ignore_filetypes = { "python", "vim", "lua", "rust" } }),
				},
			})
		end,
	},
	{ "nvim-neotest/neotest-python", dependencies = { "nvim-neotest/neotest" } },
	{ "rouge8/neotest-rust", dependencies = { "nvim-neotest/neotest" } },
	{ "nvim-neotest/neotest-plenary", dependencies = { "nvim-neotest/neotest" } },
	{ "nvim-neotest/neotest-vim-test", dependencies = { "nvim-neotest/neotest" } },
	{ "vim-test/vim-test", dependencies = { "nvim-neotest/neotest-vim-test" } },
	{
		"folke/neodev.nvim",
		opts = {
			library = {
				enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
				-- these settings will be used for your Neovim config directory
				runtime = true, -- runtime path
				types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
				plugins = true, -- installed opt or start plugins in packpath
				-- you can also specify the list of plugins to make available as a workspace library
				-- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
			},
			setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
			-- for your Neovim config directory, the config.library settings will be used as is
			-- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
			-- for any other directory, config.library.enabled will be set to false
			override = function(root_dir, options) end,
			-- With lspconfig, Neodev will automatically setup your lua-language-server
			-- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
			-- in your lsp start options
			lspconfig = true,
			-- much faster, but needs a recent built of lua-language-server
			-- needs lua-language-server >= 3.6.0
			pathStrict = true,
		},
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
			require("hlslens").setup()

			local kopts = { noremap = true, silent = true }

			vim.api.nvim_set_keymap(
				"n",
				"n",
				[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
				kopts
			)
			vim.api.nvim_set_keymap(
				"n",
				"N",
				[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
				kopts
			)
			vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
			vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
			vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
			vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
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
			notify.setup({
				background_colour = "#ffffff",
				minimum_width = 40,
				max_width = 60,
				timeout = 750,
			})
			vim.notify = notify
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*",
				callback = function()
					require("lazygit.utils").project_root_dir()
				end,
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			local function nN(char)
				local ok, winid = hlslens.nNPeekWithUFO(char)
				if ok and winid then
					-- Safe to override buffer scope keymaps remapped by ufo,
					-- ufo will restore previous buffer keymaps before closing preview window
					-- Type <CR> will switch to preview window and fire `trace` action
					vim.keymap.set("n", "<CR>", function()
						local keyCodes = api.nvim_replace_termcodes("<Tab><CR>", true, false, true)
						api.nvim_feedkeys(keyCodes, "im", false)
					end, { buffer = true })
				end
			end

			vim.keymap.set({ "n", "x" }, "n", function()
				nN("n")
			end)
			vim.keymap.set({ "n", "x" }, "N", function()
				nN("N")
			end)
			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		-- event = { "BufWritePre" },
		-- cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		-- Everything in opts will be passed to setup()
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff", "isort", "black" },
				javascript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				rust = { "rustfmt" },
			},
			-- Set up format-on-save
			-- format_on_save = { timeout_ms = 500, lsp_fallback = true },
			-- Customize formatters
			-- formatters = {
			-- 	shfmt = {
			-- 		prepend_args = { "-i", "2" },
			-- 	},
			-- },
		},
		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-telescope/telescope.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			position = "bottom", -- position of the list can be: bottom, top, left, right
			height = 10, -- height of the trouble list when position is top or bottom
			width = 50, -- width of the list when position is left or right
			icons = true, -- use devicons for filenames
			mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
			severity = nil, -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
			fold_open = "", -- icon used for open folds
			fold_closed = "", -- icon used for closed folds
			group = true, -- group results by file
			padding = true, -- add an extra new line on top of the list
			cycle_results = true, -- cycle item list when reaching beginning or end of list
			action_keys = { -- key mappings for actions in the trouble list
				-- map to {} to remove a mapping, for example:
				-- close = {},
				close = "q", -- close the list
				cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
				refresh = "r", -- manually refresh
				jump = { "<cr>", "<tab>", "<2-leftmouse>" }, -- jump to the diagnostic or open / close folds
				open_split = { "<c-x>" }, -- open buffer in new split
				open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
				open_tab = { "<c-t>" }, -- open buffer in new tab
				jump_close = { "o" }, -- jump to the diagnostic and close the list
				toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
				switch_severity = "s", -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
				toggle_preview = "P", -- toggle auto_preview
				hover = "K", -- opens a small popup with the full multiline message
				preview = "p", -- preview the diagnostic location
				open_code_href = "c", -- if present, open a URI with more information about the diagnostic error
				close_folds = { "zM", "zm" }, -- close all folds
				open_folds = { "zR", "zr" }, -- open all folds
				toggle_fold = { "zA", "za" }, -- toggle fold of current file
				previous = "k", -- previous item
				next = "j", -- next item
				help = "?", -- help menu
			},
			multiline = true, -- render multi-line messages
			indent_lines = true, -- add an indent guide below the fold icons
			win_config = { border = "single" }, -- window configuration for floating windows. See |nvim_open_win()|.
			auto_open = false, -- automatically open the list when you have diagnostics
			auto_close = false, -- automatically close the list when you have no diagnostics
			auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
			auto_fold = false, -- automatically fold a file trouble list at creation
			auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
			include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions" }, -- for the given modes, include the declaration of the current symbol in the results
			signs = {
				-- icons / text used for a diagnostic
				error = "",
				warning = "",
				hint = "",
				information = "",
				other = "",
			},
			use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
		},
	},

	-- for dap
	-- {
	--   "mfussenegger/nvim-dap",
	--   dependencies = {
	--     "mfussenegger/nvim-dap",
	--   },
	--   config = function()
	--     -- vim.keymap.set(n, '<leader>dk', function() require('dap').continue() end)
	--     -- vim.keymap.set(n, '<leader>dl', function() require('dap').run_last() end)
	--     -- vim.keymap.set(n, '<leader>b', function() require('dap').toggle_breakpoint() end)
	--   end
	-- },
	-- {
	--   "jay-babu/mason-nvim-dap.nvim",
	--   config = function()
	--     local SETTINGS = {
	--       -- A list of adapters to install if they're not already installed.
	--       -- This setting has no relation with the `automatic_installation` setting.
	--       ensure_installed = {},
	--
	--       -- NOTE: this is left here for future porting in case needed
	--       -- Whether adapters that are set up (via dap) should be automatically installed if they're not already installed.
	--       -- This setting has no relation with the `ensure_installed` setting.
	--       -- Can either be:
	--       --   - false: Daps are not automatically installed.
	--       --   - true: All adapters set up via dap are automatically installed.
	--       --   - { exclude: string[] }: All adapters set up via mason-nvim-dap, except the ones provided in the list, are automatically installed.
	--       --       Example: automatic_installation = { exclude = { "python", "delve" } }
	--       automatic_installation = false,
	--
	--       -- See below on usage
	--       handlers = nil,
	--     }
	--     require("mason-nvim-dap").setup(SETTINGS)
	--   end
	-- },
	-- {
	--   "rcarriga/nvim-dap-ui",
	--   dependencies = { "mfussenegger/nvim-dap" },
	--   {
	--     "folke/neodev.nvim",
	--     opts = {},
	--     config = function()
	--       require("neodev").setup({
	--         library = { plugins = { "nvim-dap-ui" }, types = true },
	--       })
	--     end
	--   }
	-- }
	-- dap end
}
