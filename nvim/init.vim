"エンコーディング
"GUI版使ってるなら無効にした方がいいらしいです
set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8

"カーソル位置表示
set ruler
"行番号表示
set number

"色
set background=dark

"行番号の色や現在行の設定
autocmd ColorScheme * highlight LineNr ctermfg=12
highlight CursorLineNr ctermbg=4 ctermfg=0
set cursorline
highlight clear CursorLine

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
set smarttab

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

";;でノーマルモード
inoremap <silent> ;' <esc>

"ノーマルモードのまま改行
nnoremap <CR> A<CR><ESC>
"ノーマルモードのままスペース
nnoremap <space> i<space><esc>

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

" w!!でsudo保存
cabbr w!! w !sudo tee > /dev/null %

"dein Scripts-----------------------------

if &compatible
  set nocompatible               " Be iMproved
endif

"" Required:
""set runtimepath+=/Users/faluna/.cache/dein/repos/github.com/Shougo/dein.vim

" dein.vimのディレクトリ
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

"dein.vimがない場合，githubから落としてくる
if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
endif
execute 'set runtimepath^=' . s:dein_repo_dir

" Required:
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " Let dein manage dein
  " Required:
  ""call dein#add('/Users/faluna/.cache/dein/repos/github.com/Shougo/dein.vim')

  "" Add or remove your plugins here like this:
  ""call dein#add('Shougo/neosnippet.vim')
  ""call dein#add('Shougo/neosnippet-snippets')

  " Required:
  ""call dein#end()
  ""call dein#save_state()

  " dein.toml, dein_layz.tomlファイルのディレクトリをセット
  let s:toml_dir = expand('~/.config/nvim/dein')
  
  " 起動時に読み込むプラグイン群
  call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})
  
  " 遅延読み込みしたいプラグイン群
  call dein#load_toml(s:toml_dir . '/dein_lazy.toml', {'lazy': 1})
  
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

" nerdtree起動,<C-a>
" nnoremap <silent><C-a> :NERDTreeToggle<CR>

set signcolumn=yes

" python path
let g:python3_host_prog = expand('/usr/local/bin/python3')
let g:python_host_prog = expand('/usr/local/bin/python2')

" appear " for json
autocmd Filetype json setl conceallevel=0

" *.m is FILETYPE "matlab"
au BufRead,BufNewFile *.m setfiletype matlab

" command line 補完
set wildmode=list,full

inoremap <C-l> <C-x><C-o>

nnoremap <ESC><ESC> :noh<CR>
