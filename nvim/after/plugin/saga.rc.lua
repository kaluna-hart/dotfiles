local saga = require("lspsaga")
local action = require("lspsaga.action")

saga.init_lsp_saga({
	-- Options with default value
	-- "single" | "double" | "rounded" | "bold" | "plus"
	border_style = "single",
	--the range of 0 for fully opaque window (disabled) to 100 for fully
	--transparent background. Values between 0-30 are typically most useful.
	saga_winblend = 20,
	-- when cursor in saga window you config these to move
	move_in_saga = { prev = "<C-p>", next = "<C-n>" },
	-- Error, Warn, Info, Hint
	-- use emoji like
	-- { "🙀", "😿", "😾", "😺" }
	-- or
	-- { "😡", "😥", "😤", "😐" }
	-- and diagnostic_header can be a function type
	-- must return a string and when diagnostic_header
	-- is function type it will have a param `entry`
	-- entry is a table type has these filed
	-- { bufnr, code, col, end_col, end_lnum, lnum, message, severity, source }
	diagnostic_header = { " ", " ", " ", "ﴞ " },
	-- show diagnostic source
	show_diagnostic_source = true,
	-- add bracket or something with diagnostic source, just have 2 elements
	diagnostic_source_bracket = {},
	-- preview lines of lsp_finder and definition preview
	max_preview_lines = 10,
	-- use emoji lightbulb in default
	code_action_icon = "💡",
	-- if true can press number to execute the codeaction in codeaction window
	code_action_num_shortcut = true,
	-- same as nvim-lightbulb but async
	code_action_lightbulb = {
		enable = true,
		sign = true,
		enable_in_insert = true,
		sign_priority = 20,
		virtual_text = true,
	},
	-- finder icons
	finder_icons = {
		def = "  ",
		ref = "諭 ",
		link = "  ",
	},
	-- finder do lsp request timeout
	-- if your project big enough or your server very slow
	-- you may need to increase this value
	finder_request_timeout = 1500,
	finder_action_keys = {
		open = "o",
		vsplit = "s",
		split = "i",
		tabe = "t",
		quit = "q",
		scroll_down = "<C-f>",
		scroll_up = "<C-b>", -- quit can be a table
	},
	code_action_keys = {
		quit = "q",
		exec = "<CR>",
	},
	rename_action_quit = "<C-c>",
	rename_in_select = true,
	definition_preview_icon = "  ",
	-- show symbols in winbar must nightly
	symbol_in_winbar = {
		in_custom = false,
		enable = false,
		separator = " ",
		show_file = true,
		click_support = false,
	},
	-- show outline
	show_outline = {
		win_position = "right",
		--set special filetype win that outline window split.like NvimTree neotree
		-- defx, db_ui
		win_with = "",
		win_width = 30,
		auto_enter = true,
		auto_preview = true,
		virt_text = "┃",
		jump_key = "o",
		-- auto refresh when change buffer
		auto_refresh = true,
	},
})

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>l[", "<Cmd>Lspsaga diagnostic_jump_next<CR>", opts)
vim.keymap.set("n", "<leader>l]", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
vim.keymap.set("n", "<leader>ldl", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })
vim.keymap.set("n", "<leader>ldc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })
vim.keymap.set("n", "<leader>lh", "<Cmd>Lspsaga hover_doc<CR>", opts)
vim.keymap.set("n", "<C-f>", function()
	action.smart_scroll_with_saga(1)
end, { silent = true })
-- scroll up hover doc
vim.keymap.set("n", "<C-b>", function()
	action.smart_scroll_with_saga(-1)
end, { silent = true })
vim.keymap.set("n", "<leader>llf", "<Cmd>Lspsaga lsp_finder<CR>", opts)
vim.keymap.set("n", "<leader>ls", "<Cmd>Lspsaga signature_help<CR>", opts)
vim.keymap.set("i", "<c-s>", "<Cmd>Lspsaga signature_help<CR>", opts)
vim.keymap.set("n", "<leader>ld", "<Cmd>Lspsaga preview_definition<CR>", opts)
vim.keymap.set("n", "<leader>lrn", "<Cmd>Lspsaga rename<CR>", opts)
vim.keymap.set("n", "<leader>lc", "<cmd>Lspsaga code_action<CR>", { silent = true })
vim.keymap.set("v", "<leader>lc", "<cmd><C-U>Lspsaga range_code_action<CR>", { silent = true })
vim.keymap.set("n", "<leader>lo", "<cmd>LSoutlineToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>df", "<cmd>Lspsaga open_floaterm custom_cli_command<CR>", { silent = true })
vim.keymap.set("t", "<leader>df", "<C-\\><C-n><cmd>Lspsaga close_floaterm<CR>", { silent = true })

vim.cmd([[highlight link LspSagaFinderSelection Search]])

vim.cmd([[autocmd! CursorHold,CursorHoldI * Lspsaga show_cursor_diagnostics]])