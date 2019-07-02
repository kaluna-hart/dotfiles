let g:neosnippet#enable_complete_done = 1
" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory = '~/.cache/dein/repos/github.com/honza/vim-snippets/snippets, $XDG_CONFIG_HOME/nvim/snippets'
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
