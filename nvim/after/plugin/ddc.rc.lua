vim.cmd([[
 call ddc#custom#patch_global('sources', ['nvim-lsp', 'around', 'vsnip', 'omni', 'file'])
 call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \ 'matchers': ['matcher_head'],
      \ 'sorters': ['sorter_rank'],
      \ 'converters': ['converter_remove_overlap'],
      \ },
      \ 'around': {'mark': 'A'},
      \ 'nvim-lsp': {
      \ 'mark': 'L',
      \ 'forceCompletionPattern': '\.\w*|:\w*|->\w*',
      \ },
      \ 'omni': {'mark': 'O'},
      \ 'file': {
      \   'mark': 'F',
      \   'isVolatile': v:true,
      \   'forceCompletionPattern': '\S/\S*',
      \ },
      \ })

 call ddc#custom#patch_global('sourceParams', {
      \ 'around': {'maxSize': 500},
      \ })


 inoremap <silent><expr> <TAB>
      \ ddc#map#pum_visible() ? '<C-n>' :
      \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
      \ '<TAB>' : ddc#map#manual_complete()
 inoremap <expr><S-TAB>  ddc#map#pum_visible() ? '<C-p>' : '<C-h>'


" Example: Use vimtex
"call vimtex#init()
"call ddc#custom#patch_filetype(['tex'], 'sourceOptions', {
"      \ 'omni': {
"      \   'forceCompletionPattern': g:vimtex#re#deoplete
"      \ },
"      \ })

"call ddc#custom#patch_filetype(['tex'], 'sourceParams', {
"      \ 'omni': {'omnifunc': 'vimtex#complete#omnifunc'},
"      \ })

 call ddc#enable()
 ]])
