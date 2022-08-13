require("toggleterm").setup()

vim.keymap.set('n', '<leader>df', '<cmd>ToggleTerm direction=float<cr>')
vim.keymap.set('t', '<leader>df', '<cmd>ToggleTerm direction=float<cr>')
