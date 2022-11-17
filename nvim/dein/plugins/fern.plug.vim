" for devicons
let g:fern#renderer = "devicons"

" Disable listing ignored files/directories
" let g:fern_git_status#disable_ignored = 1

" Disable listing untracked files
" let g:fern_git_status#disable_untracked = 1

" Disable listing status of submodules
" let g:fern_git_status#disable_submodules = 1

" Disable listing status of directories
" let g:fern_git_status#disable_directories = 1

" autostart fern
" augroup fern_config
"   autocmd!
"   autocmd vimenter * Fern . -drawer
" augroup END

" nnoremap <c-k> :Fern . -drawer -toggle<CR>
