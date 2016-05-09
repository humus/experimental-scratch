"prefixes for matching classes or annotations
let s:expr_prefix = '\v\c(\@)?[[:alnum:]._]+\.'
let s:expr_suffix = '([[:alnum:]._])@!'

fun! import_cword#Import_THIS() "{{{
  if import_cword#is_this_for_import()
    let l:line_for_import = import_cword#last_import_or_package()
    let l:not_last_part = import_cword#exclude_last_part()
    call import_cword#append_if_not_appended(l:line_for_import, l:not_last_part)
    call import_cword#format_line_with_clazz(l:not_last_part)
  endif
endfunction "}}}

fun! import_cword#append_if_not_appended(line_for_import, not_last_part) "{{{
  let l:import_line = import_cword#format_import(a:not_last_part)
  let l:search_exp = substitute(l:import_line, '\.', '\.', 'g')
  if searchpos(search_exp, 'bn')[0] == 0
    call append(a:line_for_import, import_line)
  end
endfunction "}}}

fun! import_cword#format_import(not_last_part) "{{{
  "expression matches a fully.quallified.class.name
  let l:WORD = substitute(expand('<cWORD>'), '\v^\@', '', '')
  let l:last_index = matchend(l:WORD, '\C'.import_cword#find_current_class(a:not_last_part)) - 1
  return 'import ' . l:WORD[:l:last_index] . ';'
endfunction "}}}

fun! import_cword#exclude_last_part() "{{{
  let l:cur_line = getline(line('.'))
  let l:index_cword = getcurpos()[2]
  let l:prev_text = l:cur_line[: l:index_cword]
  let l:after_text = l:cur_line[l:index_cword : ]

  let l:prev_not_space = matchstr(l:prev_text, '\v.+\zs<[^[:space:]]+\ze[[:space:]\_]+\v[[:alnum:]\.]+$')
  let l:next_not_space = matchstr(l:after_text, '\v[[:alnum:]\.]+\zs[^[:alnum:]\.]')
  
  return l:prev_not_space !~ 'new' && l:next_not_space =~ '\v\('
  
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

fun! import_cword#format_line_with_clazz(not_last_part) "{{{
  let l:suffix = s:expr_suffix
  if a:not_last_part
    let l:suffix = '\ze\.'
  end
  let l:current_class = import_cword#find_current_class(a:not_last_part)
  let l:curr_expr = s:expr_prefix . '(' . l:current_class . ')' . l:suffix
  let l:formatted_line = substitute(getline(line('.')), l:curr_expr, '\1\2', 'g')
  call setline(line('.'), l:formatted_line)
endfunction "}}}

fun! import_cword#find_current_class(not_last_part) "{{{
  let l:current_class = ''
  if a:not_last_part
    let l:current_class = matchlist(expand('<cWORD>'), s:expr_prefix . '([[:alnum:]_]+)\.[[:alnum:]_]+' . s:expr_suffix)[2]
  else
    let l:current_class = matchlist(expand('<cWORD>'), s:expr_prefix . '([[:alnum:]_]+)' . s:expr_suffix)[2] 
  endif
  return l:current_class
endfunction "}}}


fun! import_cword#load() "{{{
endfunction "}}}


