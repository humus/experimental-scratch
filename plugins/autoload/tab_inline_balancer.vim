
fun! tab_inline_balancer#drop_balanced_parens(str_line) "{{{
  let ret_val = substitute(a:str_line, '\v\(\)', '', 'g')
  let ret_val = substitute(ret_val, '\v\([^\)\(]{-}\)', '', 'g')
  let ret_val = substitute(ret_val, '\v^\s+|\s+$', '', 'g')
  return ret_val
endfunction "}}}

fun! tab_inline_balancer#is_line_balanced(str_line) "{{{
  let after_drop = tab_inline_balancer#drop_balanced_parens(a:str_line)
  return after_drop !~ '\v\([^\(\)]+$|\($'
endfunction "}}}

fun! tab_inline_balancer#is_last_column() "{{{
  let line = getline('.')
  let expected_len = col('.')-1
  return len(line) == expected_len && getline('.') !~ '^[[:space:]]*$'
endfunction "}}}

fun! tab_inline_balancer#complete_unbalanced_paren() "{{{
  let last_col = tab_inline_balancer#is_last_column()
  let ok_complete = !tab_inline_balancer#is_line_balanced(getline('.'))
  let ok_complete = ok_complete && last_col

  return ok_complete ? ')' : tab_inline_balancer#complete_semicolon(last_col)
endfunction "}}}

fun! tab_inline_balancer#complete_semicolon(last_col) "{{{
  if !a:last_col || !exists('b:end_complete_char')
    return "\<Tab>"
  endif
  let last_char = getline('.')[col('.') - 2]
  if last_char == ';'
    return "\<Tab>"
  endif
  return b:end_complete_char
endfunction "}}}


" vim: et sw=2 ts=2 sts=2
