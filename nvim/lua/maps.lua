local keymap = vim.keymap

keymap.set("i", "<c-l>", "<esc>")
keymap.set("i", "<c-h>", "<BS>")

-- move corsor
keymap.set("n", "j", "gj")
keymap.set("n", "k", "gk")
keymap.set("n", "gj", "j")
keymap.set("n", "gk", "k")
keymap.set("n", "<down>", "gj")
keymap.set("n", "<up>", "gk")
keymap.set("n", "<up>", "gk")
keymap.set("n", "<s-h>", "^")
keymap.set("n", "<s-j>", "}")
keymap.set("v", "<s-j>", "}")
keymap.set("n", "<s-k>", "{")
keymap.set("v", "<s-k>", "{")
keymap.set("n", "<s-l>", "$")

keymap.set("n", "r", "<c-r>")

-- window size
keymap.set("n", "<s-left>", "<c-w><")
keymap.set("n", "<s-right>", "<c-w>>")
keymap.set("n", "<s-up>", "<c-w>-")
keymap.set("n", "<s-down>", "<c-w>+")

-- move window
keymap.set("n", "<c-h>", "<c-w>h")
keymap.set("n", "<c-j>", "<c-w>j")
keymap.set("n", "<c-k>", "<c-w>k")
keymap.set("n", "<c-l>", "<c-w>l")

-- increment and decriment
keymap.set("n", "+", "<c-a>")
keymap.set("n", "-", "<c-x>")

-- search jump
keymap.set("n", "n", "nzz")
keymap.set("n", "N", "Nzz")
keymap.set("n", "*", "*zz")
keymap.set("n", "#", "#zz")
keymap.set("n", "g*", "g*zz")
keymap.set("n", "g#", "g#zz")

keymap.set("n", "<esc><esc>", ":noh<cr>")
