" coc extension lists that I want to install when installing coc.
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-yank',
  \ 'coc-snippets',
  \ 'coc-omni',
  \ 'coc-neosnippet',
  \ 'coc-lists',
  \ 'coc-highlight',
  \ 'coc-git',
  \ 'coc-emmet',
  \ 'coc-yaml',
  \ 'coc-rust-analyzer',
  \ 'coc-python',
  \ 'coc-json',
  \ 'coc-markdownlint',
  \ 'coc-html',
  \ 'coc-css',
  \ ]

" for prettier
if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif
" for eslint
if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

nnoremap [CocLeader] <Nop>
nmap <leader>l [CocLeader]
nmap <leader>c [CocListLeader]

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" let g:coc_snippet_next = '<tab>'

" Use <c-r> to trigger completion.
"" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-r> coc#refresh()
  " inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo cain at current position.
" Coc only does snippet and additional edit on confirm.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [CocLeader][ <Plug>(coc-diagnostic-prev)
nmap <silent> [CocLeader]] <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> [CocLeader]d <Plug>(coc-definition)
nmap <silent> [CocLeader]t <Plug>(coc-type-definition)
nmap <silent> [CocLeader]i <Plug>(coc-implementation)
nmap <silent> [CocLeader]rf <Plug>(coc-references)
" Symbol renaming.
nmap <silent> [CocLeader]rn <Plug>(coc-rename)

" Use [CocLeader]h to show documentation in preview window
nnoremap <silent> [CocLeader]h :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap [CocLeader]f  <Plug>(coc-format-selected)
vmap <leader>f <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap [CocLeader]as  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap [CocLeader]ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap [CocLeader]q  <Plug>(coc-fix-current)
" nmap [CocLeader]qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
omap ic <Plug>(coc-classobj-i)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" Note coc#float#scroll works on neovim >= 0.4.3 or vim >= 8.2.0750
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> [CocLeader]s <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Set up for prettier.
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Using CocList
" Show all diagnostics
nnoremap <silent> [CocListLeader]a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> [CocListLeader]e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> [CocListLeader]c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> [CocListLeader]o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> [CocListLeader]s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> [CocListLeader]j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> [CocListLeader]k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> [CocListLeader]p  :<C-u>CocListResume<CR>h
