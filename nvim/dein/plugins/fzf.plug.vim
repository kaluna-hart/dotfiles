nnoremap [fzf] <Nop>
nmap <Leader>f [fzf]
nnoremap [fzf]f :<C-u>Files<CR>
nnoremap [fzf]g :<C-u>GFiles<CR>
nnoremap [fzf]G :<C-u>GFiles?<CR>
nnoremap [fzf]b :<C-u>Buffers<CR>
nnoremap [fzf]t :<C-u>Tags<CR>
nnoremap [fzf]j :<C-u>BTags<CR>

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R -a'

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
