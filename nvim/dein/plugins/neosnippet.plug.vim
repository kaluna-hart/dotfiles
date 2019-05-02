" snippets directory
let g:neosnippet#snippets_directory = '$XDG_CONFIG_HOME/nvim/snippets'
" Plugin key-mappings
let g:neosnippet#enable_completed_snippet = 1
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
" SuperTab like snippet behavior
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "/<Plug>(neosnippet_expand_or_jump)": "\<TAB>"
" For conceal markers
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
