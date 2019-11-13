" let g:ale_linters = {
"   \ 'typescript' : ['eslint', 'tsserver']
"   \}

" 各ツールをFixerとして登録
let g:ale_fixers = {
  \ 'javascript' : ['prettier'],
  \ 'javascript.jsx' : ['prettier'],
  \ 'typescript' : ['prettier'],
  \ 'typescript.tsx' : ['prettier'],
  \ 'html': ['prettier'],
  \ 'css': ['prettier']
  \}

  " \ 'typescript' : ['prettier-eslint'],
" ローカルの設定ファイルを考慮
let g:ale_javascript_prettier_use_local_config = 1

" ついでにFixを次項するマッピングする
" nmap <silent> <Leader>x <Plug>(ale_fix)
" ファイル保存時に自動的にFixするオプションもあるのでお好みで
let g:ale_fix_on_save = 1

" シンボルからむを表示したままにする
let g:ale_sign_column_always = 1
" 補完してくれる
let g:alecompletion_enabled = 1
" エラー行に対するマーク
let g:ale_sign_error = 'x'
let g:ale_sign_warning = '⚠'
" エラー行にカーソルを合わせた際に表示されるメッセージフォーマット
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_statusline_format = ['x %d', '⚠ %d', '⬥ ok']

set omnifunc=ale#completion#OmniFunc

" Set this. Airline will handle the rest.
" let g:airline#extensions#ale#enabled = 1

" highlight color for ale error
" highlight ALEError ctermbg=DarkMagenta

nnoremap [AleCommand] <Nop>
nmap <leader>l [AleCommand]
nnoremap <silent> [AleCommand]h :ALEHover<CR>
nnoremap <silent> [AleCommand]d :ALEGoToDefinition<CR>
nnoremap <silent> [AleCommand]r :ALEFindReferences<CR>
nnoremap <silent> [AleCommand]t :ALEGoToTypeDefinition<CR>
nnoremap <silent> [AleCommand]s :ALESymbolSearch<CR>
