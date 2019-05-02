set hidden

" settings for languages
let g:LanguageClient_serverCommands = {
  \ 'cpp' : ['clangd'],
  \ 'rust'  : ['rustup', 'run', 'stable', 'rls'],
  \ 'python'  : ['pyls'],
  \}

augroup LanguageClient_config
  autocmd!
  autocmd User LanguageClientStarted setlocal signcolumn=yes
  autocmd User LanguageClientStopped setlocal signcolumn=auto
augroup END

let g:LanguageClient_autoStart = 1
nnoremap [LnagClient] <Nop>
nmap <leader>l [LangClient]
nnoremap <silent> [LangClient]h :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> [LangClient]d :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> [LangClient]r :call LanguageClient_textDocument_rename()<CR>
nnoremap <silent> [LangClient]f :call LanguageClient_textDocument_formatting()<CR>
