nnoremap [fugitiveLeader] <Nop>
nmap <leader>g [fugitiveLeader]

nnoremap [fugitiveLeader]s :tab sp<CR>:Gstatus<CR>:only<CR>
nnoremap [fugitiveLeader]a :Gwrite<CR>
nnoremap [fugitiveLeader]c :Gcommit<CR>
nnoremap [fugitiveLeader]b :Gblame<CR>
nnoremap [fugitiveLeader]l :Git log<CR>
" abbrev for `git history`: create new quickfix tab for history
nnoremap [fugitiveLeader]h :tab sp<CR>:OGlog<CR>
nnoremap [fugitiveLeader]p :Gpush<CR>
nnoremap [fugitiveLeader]f :Gfetch<CR>
nnoremap [fugitiveLeader]d :Gvdiff<CR>
nnoremap [fugitiveLeader]r :Grebase -i<CR>
nnoremap [fugitiveLeader]g :Ggrep
nnoremap [fugitiveLeader]m :Gmerge
