let g:deol#shell_history_path = '~/.zsh_history'
" [Ctrl + o] float windowでターミナル表示
nnoremap <silent><leader>df :<C-u>Deol -split=floating<CR>
nnoremap <silent><leader>dv :<C-u>Deol -split=vertical<CR>
nnoremap <silent><leader>dh :<C-u>Deol -split=horizontal<CR>
nmap <silent><leader>db (deol_bg)
" [ESC]
tnoremap <C-[> <C-\><C-n>
tnoremap <C-h> <C-\><C-n>
