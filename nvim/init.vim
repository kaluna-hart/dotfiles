"エンコーディング
"GUI版使ってるなら無効にした方がいいらしいです
if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8

"<C-l>でノーマルモード
inoremap <silent> <c-l> <esc>
" inoremap <C-l> <C-x><C-o>
imap <silent> <c-h> <BS>

" set completeopt-=preview

" ポップアップメニューの半透明表示
" set pumblend=0
" floating ウインドウの半透明表示
" set winblend=30

" mapping leader
let mapleader = "\<Space>"

" set fonts
set guifont=Ricty\ Discord\ with-all-icons
" set guifont=Ricty\ Discord\ with-all-icons\ Regular

"カーソル位置表示
set ruler
"行番号表示
set relativenumber

" クリップボード共有
set clipboard=unnamed

"行番号の色や現在行の設定
" autocmd ColorScheme * highlight LineNr ctermfg=12
set cursorline
" highlight clear CursorLine

"オートインデント
set autoindent
set smartindent

"インデント幅
set shiftwidth=2
set softtabstop=2
set tabstop=2
set shiftround

"タブをスペースに変換
set expandtab

"ビープ音すべてを無効にする
set visualbell t_vb=

"長い行の折り返し表示
set wrap

"検索設定
"インクリメンタルサーチ
set incsearch
set inccommand=split
"ハイライト
set hlsearch
"大文字と小文字を区別しない
set ignorecase
"大文字と小文字が混在した検索のみ大文字と小文字を区別する
set smartcase
"最後尾になったら先頭に戻る
set wrapscan
"置換の時gオプションをデフォルトで有効にする
set gdefault

" set ctags
set tags=./tags;$HOME
nnoremap <C-]> g<C-]>
inoremap <C-]> <ESC>g<C-]>

"不可視文字の設定
set list
set listchars=tab:>-,eol:↲,extends:»,precedes:«,nbsp:%

"カーソル移動で行をまたげるようにする
set whichwrap=b,s,h,l,<,>,~,[,]

"バックスペースを使いやすく
set backspace=indent,eol,start
set nrformats-=octal

set pumheight=10

"対応する括弧に一瞬移動
set showmatch
set matchtime=1
source $VIMRUNTIME/macros/matchit.vim " Vimの「%」を拡張する

" function-------------------------------------------------------------
command -nargs=1 MyLineSearch let @m=<q-args> | call search('^\s*'. @m)
command -nargs=1 MyLineBackSearch let @m=<q-args> | call search('^\s*'. @m, 'b')
command MyLineSameSearch call search('^\s*'. @m)
command MyLineBackSameSearch call search('^\s*'. @m, 'b')
" ---------------------------------------------------------------------

""""""""""""""""""""""""""""""

"カーソル移動
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <down> gj
nnoremap <up> gk
noremap <S-h> ^
noremap <S-j> }
noremap <S-k> {
noremap <S-l> $

"ノーマルモードのまま改行
" nnoremap <CR> A<CR><ESC>
"ノーマルモードのままスペース
" nnoremap <space> i<space><esc>

"rだけでリドゥ
nnoremap r <C-r>

"Shift + 矢印でwindowサイズを変更
nnoremap <S-Left> <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up> <C-w>-<CR>
nnoremap <S-Down> <C-w>+<CR>

" ウインドウ移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 数字のインクリメントとデクリメントを分かりやすく
nnoremap + <C-a>
nnoremap - <C-x>

" 検索にジャンプした際に検索単語を画面中央に持ってくる
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

nnoremap <ESC><ESC> :noh<CR>
" nnoremap <silent> <c-l><c-l> :noh<CR>
nnoremap <C-f>f :MyLineSearch<Space>
nnoremap <C-f>b :MyLineBackSearch<Space>
nnoremap <C-f>; :MyLineSameSearch<CR>
nnoremap <C-f>, :MyLineBackSameSearch<CR>
onoremap <C-f>f :MyLineSearch<Space>
onoremap <C-f>b :MyLineBackSearch<Space>

" w!!でsudo保存
cabbr w!! w !sudo tee > /dev/null %

set signcolumn=yes
" command line 補完
set wildmode=list,full

" python path
let g:python3_host_prog = expand("$PYENV_ROOT/versions/neovim3.9/bin/python")
let g:python_host_prog = expand("$PYENV_ROOT/versions/neovim2/bin/python")

"色
set background=dark

autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
autocmd ColorScheme * highlight NonText ctermbg=NONE guibg=NONE
autocmd ColorScheme * highlight SpecialKey ctermbg=NONE guibg=NONE
autocmd ColorScheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE 
autocmd ColorScheme * highlight LineNr ctermbg=NONE ctermfg=12 guibg=NONE
autocmd ColorScheme * highlight Folded ctermbg=NONE guibg=NONE
autocmd ColorScheme * highlight CursorLineNr ctermbg=NONE guibg=NONE guifg=#70ace5
autocmd ColorScheme * highlight CursorLine ctermbg=NONE guibg=NONE
autocmd ColorScheme * highlight SignColumn ctermbg=NONE guibg=NONE
autocmd ColorScheme * highlight VertSplit ctermbg=NONE guibg=NONE
autocmd ColorScheme * highlight Pmenu ctermbg=NONE guibg=NONE

" highlight TabLineFill ctermbg=NONE ctermfg=NONE
" highlight StatusLine ctermbg=NONE ctermfg=NONE
" highlight ModeMsg ctermbg=NONE
" highlight airline_tabfill ctermbg=NONE guibg=NONE
" highlight airline_tabsel ctermbg=NONE
" highlight CursorLineNr ctermbg=NONE ctermfg=195

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

"dein Scripts-----------------------------

if &compatible
  set nocompatible               " Be iMproved
endif

"" Required:
""set runtimepath+=/Users/faluna/.cache/dein/repos/github.com/Shougo/dein.vim

" dein.vimのディレクトリ

"dein.vimがない場合，githubから落としてくる
if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
endif
execute 'set runtimepath+=' . s:dein_repo_dir
" execute 'set runtimepath^=' . s:dein_repo_dir

" Required:
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " Let dein manage dein
  " Required:
  ""call dein#add('/Users/faluna/.cache/dein/repos/github.com/Shougo/dein.vim')

  "" Add or remove your plugins here like this:
  ""call dein#add('Shougo/neosnippet.vim')
  ""call dein#add('Shougo/neosnippet-snippets')

  " dein.toml, dein_layz.tomlファイルのディレクトリをセット
  let s:toml_dir = expand('~/.config/nvim/dein')
  
  " 起動時に読み込むプラグイン群
  call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})
  
  " 遅延読み込みしたいプラグイン群
  call dein#load_toml(s:toml_dir . '/dein_lazy.toml', {'lazy': 1})
  
  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

" for vim-css3-syntax
augroup VimCSS3Syntax
  autocmd!

  autocmd FileType css setlocal iskeyword+=-
augroup END

" appear " for json
autocmd Filetype json setl conceallevel=0
autocmd FileType json syntax match Comment +\/\/.\+$+

" indent and tab config for golang
autocmd FileType go setlocal tabstop=4 softtabstop=4 shiftwidth=4

" colorscheme iceberg, angr, quantum, lucius, neodark, one, onedark
colorscheme quantum
syntax on
