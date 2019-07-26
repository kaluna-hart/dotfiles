" set hidden
" Not show __Flutter_Output__
let g:flutter_show_log_on_run = 0

nnoremap [VimFlutter] <Nop>
nmap <leader>F [VimFlutter]
nnoremap <silent> [VimFlutter]a :FlutterRun<CR>
nnoremap <silent> [VimFlutter]q :FlutterQuit<CR>
nnoremap <silent> [VimFlutter]r :FlutterHotReload<CR>
nnoremap <silent> [VimFlutter]R :FlutterHotRestart<CR>
nnoremap <silent> [VimFlutter]vd :FlutterVisualDebug<CR>
nnoremap <silent> [VimFlutter]s :FlutterSplit<CR>
nnoremap <silent> [VimFlutter]t :FlutterTab<CR>
nnoremap <silent> [VimFlutter]vs :FlutterVSplit<CR>
nnoremap <silent> [VimFlutter]d :FlutterDevices<CR>
nnoremap <silent> [VimFlutter]e :FlutterEmulators<CR>
nnoremap <silent> [VimFlutter]e :FlutterEmulators<CR>
