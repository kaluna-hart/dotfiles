let g:coc_explorer_global_presets = {
\   'default': {
\     'width': 30,
\   },
\   '.vim': {
\     'root-uri': '~/.vim',
\   },
\   'tab': {
\     'position': 'tab',
\     'quit-on-open': v:true,
\   },
\   'floating': {
\     'position': 'floating',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingTop': {
\     'position': 'floating',
\     'floating-position': 'center-top',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingLeftside': {
\     'position': 'floating',
\     'floating-position': 'left-center',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingRightside': {
\     'position': 'floating',
\     'floating-position': 'right-center',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'simplify': {
\     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
\   }
\ }

nnoremap [ExpLeader] <Nop>
nmap <leader>e [ExpLeader]

" Use preset argument to open it
nmap <silent> [ExpLeader]d :CocCommand explorer --preset default<CR>
nmap <silent> [ExpLeader]f :CocCommand explorer --preset floatingRightside<CR>

" List all presets
nmap <silent> [ExpLeader]l :CocList explPresets<CR>

" for indentLine
let g:indentLine_fileTypeExclude = ['coc-explorer']
