local ft = require("guard.filetype")

ft("lua"):fmt("stylua"):lint("selene")
ft("typescript,javascript,typescriptreact")
	:fmt("prettier")
	-- :append({ cmd = "rustywind", stdin = true, args = { "--stdin", "-" }, fname = true })
	:lint("eslint_d")
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
