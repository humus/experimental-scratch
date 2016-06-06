
command! Importthis call import_cword#Import_THIS()

inoremap  :ImportThis<cr>
nnoremap  :ImportThis<cr>

command! -nargs=* SeePalette call j#show_palette(<f-args>)

