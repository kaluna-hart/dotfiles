"-------------
"sass
"-------------

""{{{
  let g:sass_compile_auto = 1
  let g:sass_compile_cdloop = 5
  let g:sass+_compile_cssdir = ['css', 'stylesheet']
  let g:sass_compile_file = ['scss', 'sass']
  let g:sass_started_dirs = []

  autocmd FileType less, sass setlocal sw=2 sts=2 ts=2 et
  au! BufWritePost * SassCompile
"}}}
