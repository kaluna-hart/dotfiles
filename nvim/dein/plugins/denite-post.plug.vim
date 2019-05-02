" denite/insert モードの時は，C- で移動できるようにする
call denite#custom#map('insert', "<C-j>", '<denite:move_to_next_line')
call denite#custom#map('insert', "<C-k>", '<denite:move_to_previous_line>')

" tabopenやvsplitのキーバインドを割り当て
call denite#custom#map('insert', "<C-t>", '<denite:do_action:tabopen>')
call denite#custom#map('insert', "<C-v>", '<denite:do_action:vsplit>')
call denite#custom#map('normal', "v", '<denite:do_action:vsplit>')

" ;'でdenite/insertを抜けるようにする
call denite#custom#map('insert', ";'", '<denite:enter_mode:normal>')

" ESCキーでdeniteを終了
call denite#custom#map('normal', '<esc>', '<denite:quit>', 'noremap')

call denite#custom#option('default', 'prompt', '>')

if executable('rg')
  call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])
  call denite#custom#var('file_rec', 'command', ['rg', '--files', '--glob', '!.git'])
  call denite#custom#var('grep', 'command', ['rg', '--threads', '1'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading'])
endif
