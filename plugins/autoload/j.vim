
"This variable lets me return to previous position when change
"window or alter buffer context with the plugin
let s:position = []
let g:palette_window_name='session current palette'

fun! j#load() "{{{
endfunction "}}}

fun! j#paletethis() "{{{
  let l:pos = searchpos('\v^package [^;]+;', 'bn')[1]
  let l:mypackage = matchstr(getline(l:pos), '\vpackage \zs([^;]+)\ze;', '\1', '')
  let l:myfqcn = l:mypackage . '.' . expand('%:t:r')

  let @p=l:myfqcn
  echo l:mypackage
endfunction "}}}

fun! j#show_palette() "{{{
  let l:working_window = bufwinnr('%')
  call j#prepare_palette_window()
  execute l:working_window . 'wincmd w'
  call j#maps_for_driving_palette()
endfunction "}}}

fun! j#move_line_inpalette(direction) "{{{
  let l:cur_win = bufwinnr('%')
  exe 'noautocmd keepalt '. bufwinnr(g:palette_window_name) . 'wincmd w'
  let l:pos = getcurpos()
  let new_line = l:pos[1] + a:direction
  if new_line > 0 && new_line <= line('$')
    let l:pos[1] += a:direction
    call setpos('.', l:pos)
    set cursorline! | set cursorline! "cursorline doesn't redraw by just moving it :redraw is slow. This is better
  endif
  exe 'noautocmd ' . l:cur_win . 'wincmd w'
endfunction "}}}

fun! j#maps_for_driving_palette() "{{{
  "Mappings C-J and C-K should support a count
  nnoremap <buffer><silent> <C-J> :call j#move_line_inpalette(1)<cr>
  nnoremap <buffer><silent> <C-K> :call j#move_line_inpalette(-1)<cr>
  nnoremap <buffer><silent> <C-Q> :call j#wipebuffer_revertmappings(bufnr(g:palette_window_name))<cr>

endfunction "}}}

fun! j#wipebuffer_revertmappings(the_buf) "{{{
  execute ':bw' . a:the_buf
  nunmap <buffer> <C-Q>
  nunmap <buffer> <C-J>
  nunmap <buffer> <C-K>
endfunction "}}}

fun! j#set_default_mappings_for_palette_window() "{{{
  silent! execute 'nnoremap <buffer> q :close'
endfunction "}}}

fun! j#prepare_palette_window() "{{{
  let l:palette_window = bufwinnr(g:palette_window_name)
  if l:palette_window < 0
    call j#open_palette_window()
  else
    silent! execute l:palette_window . 'wincmd w'
  endif
  call j#set_default_mappings_for_palette_window()
  call j#set_options_for_palette_window()
  call j#set_palette_window_contents()
endfunction "}}}

fun! j#set_palette_window_contents() "{{{
  call setline(1, g:palette_content[0])
  call append(1, g:palette_content[1:])
endfunction "}}}

fun! j#set_options_for_palette_window() "{{{
  setl cursorline
endfunction "}}}

fun! j#open_palette_window() "{{{
  execute join(['keepalt botright new', g:palette_window_name])
  resize 20
  setl ft='palette'
  setlocal wrap buftype=nowrite bufhidden=wipe nobuflisted noswapfile noundofile
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
