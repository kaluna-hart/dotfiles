return {
	{ "NvChad/nvim-colorizer.lua" },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		init = function()
			vim.opt.background = "light"
			vim.cmd.colorscheme("catppuccin")
		end,
		config = function()
			require("catppuccin").setup({
				flavour = "latte", -- ここでライトテーマを指定
				background = "light",
				transparent_background = true, -- ★ 背景を塗らない
				auto_integrations = true, -- 好みで有効化（入れてるプラグインの統合を自動ON）
				integrations = {
					-- bufferline = true, -- bufferlineのインテグレーションを有効化
					-- lualine = true, -- lualineのインテグレーションを有効化
					aerial = true,
					fidget = true,
					hop = true,
					lsp_saga = true,
					mason = true,
					noice = true,
					notify = true,
					sandwich = true,
					which_key = true,
				},
			})
		end,
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
			"neovim/nvim-lspconfig",
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
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
	},
	{ "nvim-telescope/telescope.nvim" },
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = { "tami5/sqlite.lua" },
	},
	{ "onsails/lspkind.nvim" },
	{ "nvim-tree/nvim-tree.lua" },
	{ "numToStr/Comment.nvim" },
	{
		"windwp/nvim-ts-autotag",
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
	},
	{
		"akinsho/bufferline.nvim",
		-- version = "*",
		branch = "main",
		dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
	},
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
	{
		"petertriho/cmp-git",
		dependencies = { "hrsh7th/nvim-cmp" },
		opts = {
			-- options go here
		},
		init = function()
			table.insert(require("cmp").get_config().sources, { name = "cmp_git" })
		end,
	},
	{ "ray-x/cmp-treesitter" },
	"rafamadriz/friendly-snippets",
	"j-hui/fidget.nvim",
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
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
	-- {
	-- 	"sourcegraph/sg.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- 	config = function()
	-- 		require("sg").setup({
	-- 			-- Pass your own custom attach function
	-- 			--    If you do not pass your own attach function, then the following maps are provide:
	-- 			--        - gd -> goto definition
	-- 			--        - gr -> goto references
	-- 			-- on_attach = your_custom_lsp_attach_function,
	-- 		})
	-- 		-- " Example mapping for doing searches from within neovim (may change) using telescope.
	-- 		-- " (requires telescope.nvim to be installed)
	-- 		local keymap = vim.keymap.set
	-- 		keymap("n", "<leader>ct", "<Cmd>CodyToggle<CR>")
	-- 	end,
	-- },
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
		lazy = false,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
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
				python = { "ruff_format", "isort", "black", stop_after_first = true },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				rust = { "rustfmt" },
				markdown = { "mdformat", "markdownlint", stop_after_first = true },
				graphql = { "prettierd", "prettier", stop_after_first = true },
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
			local lint = require("lint")
			lint.linters_by_ft = {
				-- markdown = { "vale" },
				python = { "ruff" },
				javascript = { "eslint" },
				javascriptreact = { "eslint" },
				typescript = { "eslint" },
				typescriptreact = { "eslint" },
				lua = { "luacheck" },
			}
			vim.api.nvim_create_autocmd({ "TextChanged", "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = { { "nvim-tree/nvim-web-devicons" }, { "echasnovski/mini.icons", version = false } },
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-telescope/telescope.nvim" },
		keys = {
			{
				"<leader>td",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>tD",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>ts",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>tl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>tL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>tq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
		},
	},
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
		},
		-- comment the following line to ensure hub will be ready at the earliest
		cmd = "MCPHub", -- lazy load by default
		build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
		-- uncomment this if you don't want mcp-hub to be available globally or can't use -g
		-- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
		config = function()
			require("mcphub").setup({
				auto_approve = false,
			})
		end,
	},
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			-- add any opts here
			-- for example
			provider = "ollama",
			providers = {
				ollama = {
					endpoint = "http://localhost:11434",
					model = "qwen2.5-coder:7b",
				},
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim", -- for input provider dressing
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("hlchunk").setup({
				chunk = {
					enable = true,
					style = "#806d9c",
				},
				indent = {
					enable = true,
				},
				blank = {
					enable = true,
				},
			})
		end,
	},
	{
		"moonbit-community/moonbit.nvim",
		ft = { "moonbit" },
		opts = {
			mooncakes = {
				virtual_text = true, -- virtual text showing suggestions
				use_local = true, -- recommended, use index under ~/.moon
			},
			-- optionally disable the treesitter integration
			treesitter = {
				enabled = true,
				-- Set false to disable automatic installation and updating of parsers.
				auto_install = true,
			},
			-- configure the language server integration
			-- set `lsp = false` to disable the language server integration
			lsp = {
				-- provide an `on_attach` function to run when the language server starts
				on_attach = function(client, bufnr) end,
				-- provide client capabilities to pass to the language server
				capabilities = vim.lsp.protocol.make_client_capabilities(),
			},
		},
	},
	{
		"johnseth97/codex.nvim",
		lazy = true,
		cmd = { "Codex", "CodexToggle" }, -- Optional: Load only on command execution
		keys = {
			{
				"<leader>cc", -- Change this to your preferred keybinding
				function()
					require("codex").toggle()
				end,
				desc = "Toggle Codex popup",
			},
		},
		opts = {
			keymaps = {
				toggle = nil, -- Keybind to toggle Codex window (Disabled by default, watch out for conflicts)
				quit = "<C-q>", -- Keybind to close the Codex window (default: Ctrl + q)
			}, -- Disable internal default keymap (<leader>cc -> :CodexToggle)
			border = "rounded", -- Options: 'single', 'double', or 'rounded'
			width = 0.8, -- Width of the floating window (0.0 to 1.0)
			height = 0.8, -- Height of the floating window (0.0 to 1.0)
			model = nil, -- Optional: pass a string to use a specific model (e.g., 'o3-mini')
			autoinstall = true, -- Automatically install the Codex CLI if not found
		},
	},
}
