" flake8をlinterとして登録
let g:ale_linters = {
 \ 'python': ['flake8'],
 \}

" 各ツールをFixerとして登録
" let g:ale_fixers = {
" \ 'python': ['autopep8', 'black', 'isort'],
" \}

" 各ツールの実行オプションを変更してPythonパスを固定
" let g:ale_python_flake8_executable = g:python3_host_prog
" let g:ale_python_flake8_options = '-m flake8'
" let g:ale_python_autopep8_executable = g:python3_host_prog
" let g:ale_python_autopep8_options = '-m autopep8'
" let g:ale_pythonisort_executable = g:python3_host_prog
" let g:ale_python_isort_options = '-m isort'
" let g:ale_python_black_executable = g:python3_host_prog
" let g:ale_python_black_options = '-m black'

" ついでにFixを次項するマッピングする
" nmap <silent> <Leader>x <Plug>(ale_fix)
" ファイル保存時に自動的にFixするオプションもあるのでお好みで
let g:ale_fix_on_save = 1

" シンボルからむを表示したままにする
let g:ale_sign_column_always = 1
" 補完してくれる
" let g:alecompletion_enabled = 1
" エラー行に対するマーク
let g:ale_sign_error = 'x'
let g:ale_sign_warning = '⚠'
" エラー行にカーソルを合わせた際に表示されるメッセージフォーマット
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_statusline_format = ['x %d', '⚠ %d', '⬥ ok']

