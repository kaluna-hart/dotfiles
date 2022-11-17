vim.cmd("autocmd!")

vim.scriptencoddings = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.wo.number = true

vim.opt.guifont = "HackGenNerd Console"
vim.opt.title = true -- window title bar
vim.opt.autoindent = true -- 前のインデントを継続
vim.opt.smartindent = true -- 改行時のインデントの増減
vim.opt.hlsearch = true --  検索結果をハイライト表示
vim.opt.backup = false
vim.opt.showcmd = true -- 入力中のコマンド表示
vim.opt.cmdheight = 2 -- コマンドラインの行数
vim.opt.laststatus = 2 -- ステータスラインを常時表示させる眞美からの行数
vim.opt.expandtab = true -- タブ入力を空白に変える
vim.opt.scrolloff = 10 -- スクロール時の余白行数
vim.opt.shell = "zsh" -- terminal時に起動するshell
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" } -- backup処理をしないディレクトリ
vim.opt.inccommand = "split"
vim.opt.ignorecase = true -- 検索で大文字小文字を区別しない
vim.opt.smarttab = true -- 行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする
vim.opt.breakindent = true -- 行を折り返しするときにインデントを考慮する
vim.opt.shiftwidth = 2 -- 自動で挿入/削除されるインデントの量
vim.opt.tabstop = 2 -- タブ文字の表示幅
vim.opt.wrap = true -- 長い行の折り返し
vim.opt.backspace = { "start", "eol", "indent" } -- バックスペースを有効化
vim.opt.path:append({ "**" }) --
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.ruler = true -- カーソル位置表示
vim.opt.relativenumber = true
vim.opt.smartcase = true
vim.opt.gdefault = true
vim.opt.tags = "./tags;$HOME"
vim.opt.whichwrap = "b,s,h,l,<,>,~,[,]"
vim.opt.formatoptions:append({ "r" })
vim.opt.signcolumn = "yes"
vim.opt.wildmode = "list,full"
vim.opt.cursorline = true

vim.cmd([[let &t_Cs = "\e[4:3m"]]) -- undercurl
vim.cmd([[let &t_Ce = "\e[4:0m"]]) -- undercurl

vim.g.mapleader = " "
