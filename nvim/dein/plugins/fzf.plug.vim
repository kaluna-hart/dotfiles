nnoremap [fzf] <Nop>
nmap <Leader>f [fzf]
nnoremap [fzf]f :<C-u>Files<CR>
nnoremap [fzf]g :<C-u>GFiles<CR>
nnoremap [fzf]G :<C-u>GFiles?<CR>
nnoremap [fzf]b :<C-u>Buffers<CR>
nnoremap [fzf]t :<C-u>Tags<CR>
nnoremap [fzf]j :<C-u>BTags<CR>

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R'
" autocmd BufNewFile,BufRead *.ts,*tsx let g:fzf_tags_command='tstags -R'

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" floating window for fzf
let g:fzf_layout = { 'window': 'call FloatingFZF()' }
function! FloatingFZF() abort
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = &lines - 3
  let width =float2nr((&columns - ($columns * 2 / 10)))
  let col = float2nr((&columns - width) / 2)

  let opts = {
        \ 'relative': 'editor',
        \ 'row': 1,
        \ 'col': col,
        \ 'width': width,
        \ 'height': height
        \ }
  call nvim_open_win(buf, v:true, opts)
endfunction
