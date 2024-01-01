local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local status, null_ls = pcall(require, "null-ls")
if not status then
  return
end

-- local mason_null_ls = require("mason-null-ls")
-- mason_null_ls.setup({
-- 	ensure_installed = { "stylua", "jq", "prettierd" },
-- })

-- mason_null_ls.setup_handlers({
-- 	function(source_name)
-- 		-- all sources with no handler get passed here
-- 	end,
-- 	stylua = function()
-- 		null_ls.register(null_ls.builtins.formatting.stylua)
-- 	end,
-- 	jq = function()
-- 		null_ls.register(null_ls.builtins.formatting.jq)
-- 	end,
-- })

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.formatting.stylua,
    --   null_ls.builtins.diagnostics.pylint.with({
    -- 	diagnostics_postprocess = function(diagnostic)
    -- 		diagnostic.code = diagnostic.message_id
    -- 	end,
    -- }),
    null_ls.builtins.formatting.isort,   -- for python
    null_ls.builtins.formatting.black,   -- for python
    null_ls.builtins.formatting.taplo,   -- for toml
    null_ls.builtins.diagnostics.hadolint, -- for Dockerfile
    null_ls.builtins.formatting.yamlfmt, -- for yaml
  },
  -- you can reuse a shared lspconfig on_attach callback here
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      -- vim.api.nvim_create_autocmd("BufWritePre", {
      -- 	group = augroup,
      -- 	buffer = bufnr,
      -- 	callback = function()
      -- 		-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
      -- 		vim.lsp.buf.format()
      -- 	end,
      -- })
    end
  end,
})
