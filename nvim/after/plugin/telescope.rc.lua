local keymap = vim.keymap

keymap.set('n', '[telescope]', '<nop>')
keymap.set('n', '<leader>f', '[telescope]', { remap = true })
keymap.set('n', '[telescope]f', '<cmd>Telescope find_files hidden=true<cr>')
keymap.set('n', '[telescope]l', '<cmd>Telescope live_grep<cr>')
keymap.set('n', '[telescope]b', '<cmd>Telescope buffers<cr>')
keymap.set('n', '[telescope]h', '<cmd>Telescope oldfiles<cr>')
keymap.set('n', '[telescope]g', '<cmd>Telescope git_branches<cr>')
