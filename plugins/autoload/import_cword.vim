fun! import_cword#Import_THIS() "{{{
  let l:line_for_import = import_cword#last_import_or_package()
  if import_cword#is_this_for_import()
    call append(l:line_for_import, import_cword#format_import())
  endif
endfunction "}}}

fun! import_cword#format_import() "{{{
  let l:import = substitute(expand('<cWORD>'), '\v[[:alnum:]\.]+\zs[^[:alnum:]]+', '', '')
  let l:import = substitute(l:import, '\v[^[:alnum:]]+\ze[[:alnum:]]', '', '')
  return 'import ' . l:import . ';'
endfunction "}}}

fun! import_cword#is_this_for_import() "{{{
  let l:col = col('.') - 1
  let l:line = getline(line('.'))
  if l:line[l:col] !~ '\c\v[a-z.$@]'
    return 0
  endif
  return 1
endfunction "}}}

fun! import_cword#last_import_or_package() "{{{
  let l:pos = searchpos('\vimport [[:alnum:].]+[[:alnum:]];|^package .+;', 'bn')[0]
  return l:pos
endfunction "}}}


command! Importthis call import_cword#Import_THIS()
