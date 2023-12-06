local ft = require("guard.filetype")

ft("lua"):fmt("lsp"):append("stylua")
ft("typescript,javascript,typescriptreact"):fmt("dprint")
ft("python"):fmt("ruff"):lint("ruff")
ft("rust"):fmt("rustfmt")
ft("graphql"):fmt("prettier")
ft("markdown"):fmt("prettier"):append("dprint")

require("guard").setup({
	-- the only options for the setup function
	fmt_on_save = false,
	-- Use lsp if no formatter was defined for this filetype
	lsp_as_default_formatter = true,
})

vim.keymap.set({ "n", "v" }, "<leader>gf", "<cmd>GuardFmt<CR>")
