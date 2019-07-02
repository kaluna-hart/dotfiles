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
  \ 'dart' : ['dart_language_server'],
  \ }

augroup LanguageClient_config
  autocmd!
  autocmd User LanguageClientStarted setlocal signcolumn=yes
  autocmd User LanguageClientStopped setlocal signcolumn=auto
augroup END

let g:LanguageClient_autoStart = 1
nnoremap [LnagClient] <Nop>
nmap <leader>l [LangClient]
nnoremap <silent> [LangClient]h :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> [LangClient]d :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> [LangClient]r :call LanguageClient#textDocument_rename()<CR>
nnoremap <silent> [LangClient]f :call LanguageClient#textDocument_formatting()<CR>
nnoremap <silent> [LangClient]e :call LanguageClient#explainErrorAtPoint()<CR>
nnoremap <silent> [LangClient]t :call LanguageClient#textDocument_typeDefinition()<CR>
nnoremap <silent> [LangClient]x :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> [LangClient]a :call LanguageClient_workspace_applyEdit()<CR>
nnoremap <silent> [LangClient]c :call LanguageClient#textDocument_completion()<CR>
nnoremap <silent> [LangClient]s :call LanguageClient_textDocument_documentSymbol()<CR>
nnoremap <silent> [LangClient]m :call LanguageClient_contextMenu()<CR>
" nnoremap <silent> [LangClient]
