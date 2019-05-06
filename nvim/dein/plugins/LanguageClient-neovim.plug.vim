set hidden

" settings for languages
let g:LanguageClient_serverCommands = {
  \ 'cpp' : ['clangd'],
  \ 'rust'  : ['rustup', 'run', 'stable', 'rls'],
  \ 'python'  : ['pyls'],
  \ 'julia' : ['/Applications/Julia-1.1.app/Contents/Resources/julia/bin/julia', '--startup-file=no', '--history-file=no', '-e', '
  \ using LanguageServer;
  \ using Pkg;
  \ import StaticLint;
  \ import SymbolServer;
  \ env_path = dirname(Pkg.Types.Context().env.project_file);
  \ debug = false;
  \
  \ server = LanguageServer.LanguageServerInstance(stdin, stdout, debug, env_path, "", Dict());
  \ server.runlinter = true;
  \ run(server);
  \ '],
  \ }

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
