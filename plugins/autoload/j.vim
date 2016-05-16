
"This variable lets me return to previous position when change
"window or alter buffer context with the plugin
let s:position = []

fun! j#load() "{{{
endfunction "}}}

fun! j#paletethis() "{{{
  let l:pos = searchpos('\v^package [^;]+;', 'bn')[1]
  let l:mypackage = matchstr(getline(l:pos), '\vpackage \zs([^;]+)\ze;', '\1', '')
  let l:myfqcn = l:mypackage . '.' . expand('%:t:r')

  let @p=l:myfqcn
  echo l:mypackage
endfunction "}}}


fun! j#insert_abobe_cursor(str_for_insert) "{{{
  let s:position = getcurpos()
  call j#append_and_then_resetcursor(a:str_for_insert, s:position[1] - 1)
endfunction "}}}

fun! j#insert_below_cursor(str_for_insert) "{{{
  let s:position = getcurpos()
  call j#append_and_then_resetcursor(a:str_for_insert, s:position[1])
endfunction "}}}

fun! j#append_and_then_resetcursor(str_for_insert, line) "{{{
  call append(a:line, a:str_for_insert)
  call setpos('.', s:position)
endfunction "}}}
