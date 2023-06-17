vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.pumblend = 50
vim.opt.winblend = 30

vim.cmd([[let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"]])
vim.cmd([[let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"]])

-- vim.cmd([[highlight clear CursorLine]])

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight Normal ctermbg=NONE guibg=NONE",
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight NonText ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight SpecialKey ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight EndOfBuffer ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight LineNr ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight Folded ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight CursorLineNr ctermbg=NONE guibg=NONE guifg=#70ace5"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight CursorLine ctermbg=NONE guibg=NONE",
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight SignColumn ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight VertSplit ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight Pmenu ctermbg=NONE guibg=NONE"
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = { "*" },
  command = "highlight NormalFloat ctermbg=NONE guibg=NONE"
})

vim.cmd([[syntax on]])
vim.cmd([[colorscheme moonfly]])
