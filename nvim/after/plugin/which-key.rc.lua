local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local mappings_n = {
	{
		"<F5>",
		function()
			require("dap").continue()
		end,
		desc = "dap continue",
		nowait = true,
		remap = false,
	},
	{
		"<F10>",
		function()
			require("dap").step_over()
		end,
		desc = "dap step over",
		nowait = true,
		remap = false,
	},
	{
		"<F11>",
		function()
			require("dap").step_into()
		end,
		desc = "dap step info",
		nowait = true,
		remap = false,
	},
	{
		"<F12>",
		function()
			require("dap").step_out()
		end,
		desc = "dap step out",
		nowait = true,
		remap = false,
	},
	{ "m", "<cmd>AerialToggle! float<CR>", desc = "aerial", nowait = true, remap = false },
	{
		"[E",
		function()
			require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
		end,
		desc = "lspsaga diagnostic goto prev error",
		nowait = true,
		remap = false,
	},
	{
		"]E",
		function()
			require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
		end,
		desc = "lspsaga diagnostic goto next error",
		nowait = true,
		remap = false,
	},
	{ "<c-d>", "<cmd>Lspsaga term_toggle<cr>", desc = "lspsaga term toggle", nowait = true, remap = false },
	{ "z", group = "nvim-ufo", nowait = true, remap = false },
	{
		"zK",
		function()
			local winid = require("ufo").peekFoldedLinesUnderCursor()
			if not winid then
				vim.lsp.buf.hover()
			end
		end,
		desc = "ufo peek folded lines under cursor",
		nowait = true,
		remap = false,
	},
	{ "zM", require("ufo").closeAllFolds, desc = "ufo close all folds", nowait = true, remap = false },
	{ "zR", require("ufo").openAllFolds, desc = "ufo open all folds", nowait = true, remap = false },
	{ "zr", require("ufo").openFoldsExceptKinds, desc = "ufo open fold", nowait = true, remap = false },
	{ "zm", require("ufo").closeFoldsWith, desc = "ufo close fold", nowait = true, remap = false },
}

local mappings_n_leader = {
	{
		"<leader>L",
		function()
			vim.schedule(function()
				if require("hlslens").exportLastSearchToQuickfix() then
					vim.cmd("cw")
				end
			end)
			return ":noh<cr>"
		end,
		desc = "hlslens quickfix",
		nowait = true,
		remap = false,
	},
	{ "<leader>c", group = "cody", nowait = true, remap = false },
	{ "<leader>ct", "<cmd>CodyToggle<cr>", desc = "cody toggle", nowait = true, remap = false },
	{ "<leader>ef", "<cmd>NvimTreeToggle<cr>", group = "nvim tree", nowait = true, remap = false },
	{ "<leader>f", group = "telescope", nowait = true, remap = false },
	{ "<leader>fa", "<cmd>Telescope aerial<cr>", desc = "telescope aerial", nowait = true, remap = false },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "telescope buffers", nowait = true, remap = false },
	{ "<leader>fc", "<cmd>Telescope neoclip<cr>", desc = "telescope neoclip", nowait = true, remap = false },
	{ "<leader>fd", group = "dap", nowait = true, remap = false },
	{ "<leader>fdc", "<cmd>Telescope dap commands<cr>", desc = "telescope dap commands", nowait = true, remap = false },
	{ "<leader>fdf", "<cmd>Telescope dap frames<cr>", desc = "telescope dap frames", nowait = true, remap = false },
	{
		"<leader>fdl",
		"<cmd>Telescope dap list_breakpoints<cr>",
		desc = "telescope dap list breakpoints",
		nowait = true,
		remap = false,
	},
	{
		"<leader>fdo",
		"<cmd>Telescope dap configurations<cr>",
		desc = "telescope dap configurations",
		nowait = true,
		remap = false,
	},
	{
		"<leader>fdv",
		"<cmd>Telescope dap variables<cr>",
		desc = "telescope dap variables",
		nowait = true,
		remap = false,
	},
	{
		"<leader>ff",
		"<cmd>Telescope find_files hidden=true<cr>",
		desc = "telescope find files hidden=true",
		nowait = true,
		remap = false,
	},
	{ "<leader>fg", "<cmd>LazyGit<cr>", desc = "telescope lazygit", nowait = true, remap = false },
	{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "telescope old files", nowait = true, remap = false },
	{ "<leader>fl", "<cmd>Telescope live_grep<cr>", desc = "telescope live grep", nowait = true, remap = false },
	{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "telescope help tags", nowait = true, remap = false },
	{
		"<leader>fn",
		function()
			require("telescope").extensions.notify.notify()
		end,
		desc = "telescope notify",
		nowait = true,
		remap = false,
	},
	{ "<leader>fr", "<cmd>Telescope file_browser<cr>", desc = "telescope file browser", nowait = true, remap = false },
	{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "todo telescope", nowait = true, remap = false },
	{ "<leader>g", group = "git.nvim", nowait = true, remap = false },
	{ "<leader>gD", "<cmd>GitDiffClose<cr>", desc = "git diff close", nowait = true, remap = false },
	{ "<leader>gR", "<cmd>GitRevertFile<cr>", desc = "git revert file", nowait = true, remap = false },
	{ "<leader>gb", "<cmd>GitBlame<cr>", desc = "git blame", nowait = true, remap = false },
	{ "<leader>gd", "<cmd>GitDiff<cr>", desc = "git diff", nowait = true, remap = false },
	{ "<leader>gn", "<cmd>GitCreatePullRequest<cr>", desc = "git create pull request", nowait = true, remap = false },
	{ "<leader>gr", "<cmd>GitRevert<cr>", desc = "git revert", nowait = true, remap = false },
	{ "<leader>l", group = "lsp", nowait = true, remap = false },
	{ "<leader>lD", vim.lsp.buf.declaration, desc = "lsp declaration", nowait = true, remap = false },
	{
		"<leader>lH",
		"<cmd>Lspsaga hover_doc ++keep<cr>",
		desc = "lspsaga hover doc ++keep",
		nowait = true,
		remap = false,
	},
	{
		"<leader>l[",
		"<cmd>Lspsaga diagnostic_jump_prev<cr>",
		desc = "lspsaga diagnostic jump prev",
		nowait = true,
		remap = false,
	},
	{
		"<leader>l]",
		"<cmd>Lspsaga diagnostic_jump_next<cr>",
		desc = "lspsaga diagnostic jump next",
		nowait = true,
		remap = false,
	},
	{ "<leader>lca", "<cmd>Lspsaga code_action<cr>", desc = "lspsaga code action", nowait = true, remap = false },
	{ "<leader>lci", "<cmd>Lspsaga incoming_calls<cr>", desc = "lspsaga incoming calls", nowait = true, remap = false },
	{ "<leader>lco", "<cmd>Lspsaga outgoing_calls<cr>", desc = "lspsaga outgoing calls", nowait = true, remap = false },
	{
		"<leader>lf",
		"<cmd>Lspsaga finder tyd+ref+def<cr>",
		desc = "lspsaga finder tyd+ref+def",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lgd",
		"<cmd>Lspsaga goto_definition<cr>",
		desc = "lspsaga goto definition",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lgt",
		"<cmd>Lspsaga goto_type_definition<cr>",
		desc = "lspsaga goto type definition",
		nowait = true,
		remap = false,
	},
	{ "<leader>lh", "<cmd>Lspsaga hover_doc<cr>", desc = "lspsaga hover doc", nowait = true, remap = false },
	{ "<leader>li", vim.lsp.buf.implementation, desc = "lsp implementation", nowait = true, remap = false },
	{ "<leader>lo", "<cmd>Lspsaga outline<cr>", desc = "lspsaga outline", nowait = true, remap = false },
	{
		"<leader>lpd",
		"<cmd>Lspsaga peek_definition<cr>",
		desc = "lspsaga peek definition",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lpt",
		"<cmd>Lspsaga peek_type_definition<cr>",
		desc = "lspsaga peek type definition",
		nowait = true,
		remap = false,
	},
	{ "<leader>lrn", "<cmd>Lspsaga rename<cr>", desc = "lspsaga rename", nowait = true, remap = false },
	{
		"<leader>lrp",
		"<cmd>Lspsaga rename ++project<cr>",
		desc = "lspsaga rename ++project",
		nowait = true,
		remap = false,
	},
	{ "<leader>lrr", vim.lsp.buf.references, desc = "lsp references", nowait = true, remap = false },
	{
		"<leader>lsb",
		"<cmd>Lspsaga show_buffer_diagnostics<cr>",
		desc = "lspsaga show buffer diagnostics",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lsc",
		"<cmd>Lspsaga show_cursor_diagnostics<cr>",
		desc = "lspsaga show cursor diagnostics",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lsl",
		"<cmd>Lspsaga show_line_diagnostics<cr>",
		desc = "lspsaga show line diagnostics",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lt",
		vim.lsp.buf.type_definition,
		desc = "lsp type definition",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lwa",
		vim.lsp.buf.add_workspace_folder,
		desc = "lsp add workspace folder",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lwl",
		function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end,
		desc = "lsp list workspace folder",
		nowait = true,
		remap = false,
	},
	{
		"<leader>lwr",
		vim.lsp.buf.remove_workspace_folder,
		desc = "lsp remove workspace folder",
		nowait = true,
		remap = false,
	},
	{ "<leader>t", group = "Trouble", nowait = true, remap = false },
}

local mappings_v_leader = {
	{
		mode = { "v" },
		{ "<leader>d", group = "nvim-dap", nowait = true, remap = false },
		{ "<leader>de", '<cmd>lua require("dapui").eval()<cr>', desc = "dapui eval", nowait = true, remap = false },
		{
			"<leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "dap ui widgets hover",
			nowait = true,
			remap = false,
		},
		{
			"<leader>dp",
			function()
				require("dap.ui.widgets").preview()
			end,
			desc = "dap ui widgets preview",
			nowait = true,
			remap = false,
		},
		{ "<leader>l", group = "lsp", nowait = true, remap = false },
		{ "<leader>lca", "<cmd>Lspsaga code_action<cr>", desc = "lspsaga code action", nowait = true, remap = false },
	},
}

local mappings_x_leader = {
	{
		mode = "x", -- NORMAL mode
		"<leader>L",
		function()
			vim.schedule(function()
				if require("hlslens").exportLastSearchToQuickfix() then
					vim.cmd("cw")
				end
			end)
			return ":noh<cr>"
		end,
		desc = "hlslens quickfix",
		mode = "x",
		nowait = true,
		remap = false,
	},
}

local mappings_t = {
	{
		mode = "t", -- NORMAL mode
		{
			"<c-d>",
			"<cmd>Lspsaga term_toggle<cr>",
			desc = "lspsaga term toggle",
			mode = "t",
			nowait = true,
			remap = false,
		},
	},
}

which_key.setup()
which_key.add({ mappings_n, mappings_n_leader, mappings_v_leader, mappings_x_leader, mappings_t })
