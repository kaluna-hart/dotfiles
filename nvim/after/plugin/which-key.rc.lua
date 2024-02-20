local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local opts_n = {
	mode = "n", -- NORMAL mode
	prefix = nil,
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}
local mappings_n = {
	["<F5>"] = {
		function()
			require("dap").continue()
		end,
		"dap continue",
	},
	["<F10>"] = {
		function()
			require("dap").step_over()
		end,
		"dap step over",
	},
	["<F11>"] = {
		function()
			require("dap").step_into()
		end,
		"dap step info",
	},
	["<F12>"] = {
		function()
			require("dap").step_out()
		end,
		"dap step out",
	},
	["m"] = { "<cmd>AerialToggle! float<CR>", "aerial" },
	["["] = {
		E = {
			function()
				require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
			end,
			"lspsaga diagnostic goto prev error",
		},
	},
	["]"] = {
		E = {
			function()
				require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
			end,
			"lspsaga diagnostic goto next error",
		},
	},
	["<c-d>"] = { "<cmd>Lspsaga term_toggle<cr>", "lspsaga term toggle" },
	z = {
		name = "nvim-ufo",
		R = { require("ufo").openAllFolds, "ufo open all folds" },
		M = { require("ufo").closeAllFolds, "ufo close all folds" },
		r = { require("ufo").openFold, "ufo open fold" },
		m = { require("ufo").closeFold, "ufo close fold" },
		["<cr>"] = { require("ufo").toggleFold, "ufo toggle fold" },
		K = {
			function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end,
			"ufo peek folded lines under cursor",
		},
	},
}
local opts_n_leader = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}
local mappings_n_leader = {
	g = {
		name = "git.nvim",
		b = { "<cmd>GitBlame<cr>", "git blame" },
		n = { "<cmd>GitCreatePullRequest<cr>", "git create pull request" },
		d = { "<cmd>GitDiff<cr>", "git diff" },
		D = { "<cmd>GitDiffClose<cr>", "git diff close" },
		r = { "<cmd>GitRevert<cr>", "git revert" },
		R = { "<cmd>GitRevertFile<cr>", "git revert file" },
	},
	["ef"] = {
		name = "nvim tree",
		"<cmd>NvimTreeToggle<cr>",
		"nvim tree",
	},
	l = {
		name = "lsp",
		D = { vim.lsp.buf.declaration, "lsp declaration" },
		i = { vim.lsp.buf.implementation, "lsp implementation" },
		w = {
			a = { vim.lsp.buf.add_workspace_folder, "lsp add workspace folder" },
			r = { vim.lsp.buf.remove_workspace_folder, "lsp remove workspace folder" },
			l = {
				function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end,
				"lsp list workspace folder",
			},
		},
		t = { vim.lsp.buf.type_definition, "lsp type definition" },
		f = { "<cmd>Lspsaga finder tyd+ref+def<cr>", "lspsaga finder tyd+ref+def" },
		-- f = { function() vim.lsp.buf.format { async = true } end, "lsp format" },
		c = {
			a = { "<cmd>Lspsaga code_action<cr>", "lspsaga code action" },
			i = { "<cmd>Lspsaga incoming_calls<cr>", "lspsaga incoming calls" },
			o = { "<cmd>Lspsaga outgoing_calls<cr>", "lspsaga outgoing calls" },
		},
		r = {
			r = { vim.lsp.buf.references, "lsp references" },
			n = { "<cmd>Lspsaga rename<cr>", "lspsaga rename" },
			p = { "<cmd>Lspsaga rename ++project<cr>", "lspsaga rename ++project" },
		},
		p = {
			d = { "<cmd>Lspsaga peek_definition<cr>", "lspsaga peek definition" },
			t = { "<cmd>Lspsaga peek_type_definition<cr>", "lspsaga peek type definition" },
		},
		g = {
			d = { "<cmd>Lspsaga goto_definition<cr>", "lspsaga goto definition" },
			t = { "<cmd>Lspsaga goto_type_definition<cr>", "lspsaga goto type definition" },
		},
		s = {
			l = { "<cmd>Lspsaga show_line_diagnostics<cr>", "lspsaga show line diagnostics" },
			c = { "<cmd>Lspsaga show_cursor_diagnostics<cr>", "lspsaga show cursor diagnostics" },
			b = { "<cmd>Lspsaga show_buffer_diagnostics<cr>", "lspsaga show buffer diagnostics" },
		},
		["["] = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "lspsaga diagnostic jump prev" },
		["]"] = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "lspsaga diagnostic jump next" },
		o = { "<cmd>Lspsaga outline<cr>", "lspsaga outline" },
		h = { "<cmd>Lspsaga hover_doc<cr>", "lspsaga hover doc" },
		H = { "<cmd>Lspsaga hover_doc ++keep<cr>", "lspsaga hover doc ++keep" },
	},
	f = {
		name = "telescope",
		f = { "<cmd>Telescope find_files hidden=true<cr>", "telescope find files hidden=true" },
		l = { "<cmd>Telescope live_grep<cr>", "telescope live grep" },
		b = { "<cmd>Telescope buffers<cr>", "telescope buffers" },
		h = { "<cmd>Telescope oldfiles<cr>", "telescope old files" },
		r = { "<cmd>Telescope file_browser<cr>", "telescope file browser" },
		a = { "<cmd>Telescope aerial<cr>", "telescope aerial" },
		n = {
			function()
				require("telescope").extensions.notify.notify()
			end,
			"telescope notify",
		},
		g = { "<cmd>Telescope lazygit<cr>", "telescope lazygit" },
		d = {
			name = "dap",
			c = { "<cmd>Telescope dap commands<cr>", "telescope dap commands" },
			o = { "<cmd>Telescope dap configurations<cr>", "telescope dap configurations" },
			l = { "<cmd>Telescope dap list_breakpoints<cr>", "telescope dap list breakpoints" },
			v = { "<cmd>Telescope dap variables<cr>", "telescope dap variables" },
			f = { "<cmd>Telescope dap frames<cr>", "telescope dap frames" },
		},
		c = { "<cmd>Telescope neoclip<cr>", "telescope neoclip" },
		t = { "<cmd>TodoTelescope<cr>", "todo telescope" },
	},
	c = {
		name = "cody",
		t = { "<cmd>CodyToggle<cr>", "cody toggle" },
	},
	L = {
		function()
			vim.schedule(function()
				if require("hlslens").exportLastSearchToQuickfix() then
					vim.cmd("cw")
				end
			end)
			return ":noh<cr>"
		end,
		"hlslens quickfix",
	},
	t = {
		name = "trouble",
		x = {
			function()
				require("trouble").toggle()
			end,
			"toggle",
		},
		w = {
			function()
				require("trouble").toggle("workspace_diagnostics")
			end,
			"toggle workspace_diagnotics",
		},
		d = {
			function()
				require("trouble").toggle("document_diagnostics")
			end,
			"toggle document_diagnotics",
		},
		q = {
			function()
				require("trouble").toggle("quickfix")
			end,
			"toggle quickfix",
		},
		l = {
			function()
				require("trouble").toggle("loclist")
			end,
			"toggle loclist",
		},
		r = {
			function()
				require("trouble").toggle("lsp_references")
			end,
			"toggle lsp_references",
		},
	},
	d = {
		name = "nvim-dap",
		b = {
			function()
				require("dap").toggle_breakpoint()
			end,
			"dap toggle breakpoint",
		},
		B = {
			function()
				require("dap").set_breakpoint()
			end,
			"dap set breakpoint",
		},
		lp = {
			function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end,
			"dap log point message",
		},
		ro = {
			function()
				require("dap").repl.open()
			end,
			"dap repl open",
		},
		rl = {
			function()
				require("dap").run_last()
			end,
			"dap run last",
		},
		h = {
			function()
				require("dap.ui.widgets").hover()
			end,
			"dap ui widgets hover",
		},
		p = {
			function()
				require("dap.ui.widgets").preview()
			end,
			"dap ui widgets preview",
		},
		t = {
			function()
				require("dapui").toggle()
			end,
			"dapui toggle",
		},
		fe = {
			function()
				require("dapui").float_element()
			end,
			"dapui floating elements",
		},
		fc = {
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end,
			"dap widgets centered float frames",
		},
		s = {
			function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end,
			"dap ui widgets centered float scopes",
		},
		e = {
			function()
				require("dapui").eval()
			end,
			"dapui eval",
		},
	},
}
local opts_v_leader = {
	mode = "v", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}
local mappings_v_leader = {
	l = {
		name = "lsp",
		c = {
			a = { "<cmd>Lspsaga code_action<cr>", "lspsaga code action" },
		},
	},
	d = {
		name = "nvim-dap",
		e = {
			'<cmd>lua require("dapui").eval()<cr>',
			"dapui eval",
		},
		h = {
			function()
				require("dap.ui.widgets").hover()
			end,
			"dap ui widgets hover",
		},
		p = {
			function()
				require("dap.ui.widgets").preview()
			end,
			"dap ui widgets preview",
		},
	},
}
local opts_x_leader = {
	mode = "x", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}
local mappings_x_leader = {
	L = {
		function()
			vim.schedule(function()
				if require("hlslens").exportLastSearchToQuickfix() then
					vim.cmd("cw")
				end
			end)
			return ":noh<cr>"
		end,
		"hlslens quickfix",
	},
}
local opts_t = {
	mode = "t", -- NORMAL mode
	prefix = nil,
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}
local mappings_t = {
	["<c-d>"] = { "<cmd>Lspsaga term_toggle<cr>", "lspsaga term toggle" },
}

which_key.setup()
which_key.register(mappings_n, opts_n)
which_key.register(mappings_t, opts_t)
which_key.register(mappings_n_leader, opts_n_leader)
which_key.register(mappings_v_leader, opts_v_leader)
which_key.register(mappings_x_leader, opts_x_leader)
