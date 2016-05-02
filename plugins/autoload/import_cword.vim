fun! import_cword#Import_THIS() "{{{
  if import_cword#is_this_for_import()
    let l:line_for_import = import_cword#last_import_or_package()
    call import_cword#append_if_not_appended(l:line_for_import)
    call import_cword#format_line_with_clazz()
  endif
endfunction "}}}

fun! import_cword#append_if_not_appended(line_for_import) "{{{
  let l:import_line = import_cword#format_import()
  let l:search_exp = substitute(l:import_line, '\.', '\.', 'g')
  if searchpos(search_exp, 'bn')[0] == 0
    call append(a:line_for_import, import_line)
  end
endfunction "}}}

fun! import_cword#format_import() "{{{
  let l:import = substitute(expand('<cWORD>'), '\v[[:alnum:]\.]+\zs[^[:alnum:]\.]+.*', '', '')
  let l:import = substitute(l:import, '\v[^[:alnum:]\.]+\ze[[:alnum:]\.]', '', '')
  return 'import ' . l:import . ';'
endfunction "}}}

fun! import_cword#is_this_for_import() "{{{
  let l:col = col('.') - 1
  let l:line = getline(line('.'))
  if l:line[l:col] !~ '\c\v[_a-z0-9.$@]'
    return 0
  endif
  return 1
endfunction "}}}

fun! import_cword#last_import_or_package() "{{{
  let l:pos = searchpos('\vimport [^;]+;|^package [^;]+;', 'bn')[0]
  return l:pos
endfunction "}}}

fun! import_cword#format_line_with_clazz() "{{{
  let l:expr_prefix = '\v\c(\@)?[[:alnum:]._]+\.'
  let l:expr_suffix = '([[:alnum:]._])@!'
  let l:current_class = matchlist(expand('<cWORD>'), l:expr_prefix . '([[:alnum:]_]+)' . l:expr_suffix)[2]
  let l:line = getline(line('.'))
  let l:formatted_line = substitute(l:line,
        \ l:expr_prefix . '(' . l:current_class . ')' . l:expr_suffix, '\1\2', 'g')
  call setline(line('.'), l:formatted_line)
endfunction "}}}

fun! import_cword#load() "{{{
endfunction "}}}


