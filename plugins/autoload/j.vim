
fun! j#paletethis() "{{{
  let l:pos = searchpos('\v^package [^;]+;', 'bn')[1]
  let l:mypackage = substitute(getline(l:pos), '\vpackage ([^;]+);', '\1', '')
  let l:myfqcn = l:mypackage . '.' . expand('%:t:r')

  let @p=l:myfqcn
  echo l:mypackage
endfunction "}}}

fun! j#load() "{{{
endfunction "}}}

command! JPaletteThis call j#paletethis()
