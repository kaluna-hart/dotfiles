let g:user_emmet_mode = 'iv'
let g:user_emmet_leader_key = '<C-y>'
let g:use_emmet_complete_tag = 1
let g:user_emmet_settings = {
  \ 'variables' : {
  \   'lang' : 'ja',
  \ },
  \ 'html' : {
  \   'filters' : 'html',
  \ },
  \ 'css' : {
  \   'filters' : 'fc',
  \ },
  \ 'php' : {
  \   'extends : 'html',
  \   'filters' : 'html',
  \ },
  \}
augroup EmmitVim
  autocmd!
  autocmd FileType * let g:user_emmet_settings.indentation = '  '[:&tabstop]
augroup END
