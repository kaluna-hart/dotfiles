local ft = require("guard.filetype")

ft("lua"):fmt("lsp"):append("stylua")
ft("typescript,javascript,typescriptreact"):fmt("prettier")
ft("python"):fmt("black")
ft("rust"):fmt("rustfmt")
ft("graphql"):fmt("prettier")

require("guard").setup({
  -- the only options for the setup function
  fmt_on_save = false,
  -- Use lsp if no formatter was defined for this filetype
  lsp_as_default_formatter = false,
})

vim.keymap.set({ "n", "v" }, "<leader>gf", "<cmd>GuardFmt<CR>")
