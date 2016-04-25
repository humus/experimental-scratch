let g:maven_command='mvn -gs C:/java/.settings.xml'
let g:jar_command='C:/java/jdk1.7.0_79/bin/jar'

let g:manifest_dict = {
            \ 'archiver_version': "Archiver-Version: javavimmesss archiver",
            \ 'version': "Manifest-Version: 1.0",
            \ 'by': "Created-By: vimplugin",
            \ 'extra': 'Main-Class: org.junit.core.JUnitCore'
            \ }


fun! s:create_vimtempstuff_dir() "{{{
  if !isdirectory('.vimtempstuff')
    call mkdir('.vimtempstuff', 'p')
  endif
  
  echo "directory created"
endfunction "}}}

fun! s:create_manifest() "{{{
  
  let data=[g:manifest_dict['archiver_version'],
        \ g:manifest_dict['version'],
        \ g:manifest_dict['by']]
  
  let cpath_list = s:extract_classpath_lines()


  call writefile(data, '.vimtempstuff/manifest')
  call writefile(cpath_list, '.vimtempstuff/manifest', 'a')

endfunction "}}}

fun! s:extract_classpath_lines() "{{{

  let l:classpath_str=system(g:maven_command . ' dependency:build-classpath')
  let l:cpath=s:discard_non_classpath_lines(split(l:classpath_str, '\n'))

  return s:format_cpath_lines(l:cpath)

endfunction "}}}

fun! s:format_cpath_lines(cpath) "{{{

  if has('win32')
    let l:cpath=substitute(a:cpath, ';', ' ', 'g')
    let l:cpath=substitute(l:cpath, '\v([A-Z]):\\', '/\1:/', 'g')
    let l:cpath=substitute(l:cpath, '\\', '/', 'g')
  else
    let l:cpath=substitute(a:cpath, ':', ' ')
    let l:cpath=substitute(l:cpath, '\v^\ze/| \ze/', 'file://', 'g')
  endif
  
  let cpath=substitute(l:cpath, '\v\ze(.{65})+$', ' ','g')
  return split(l:cpath, '\v\ze(.{66})+$')
    
endfunction "}}}

fun! s:discard_non_classpath_lines(lines) "{{{
  let l:cpath='Class-Path: '
  for line in a:lines
    if line =~ 'jar$'
      let l:cpath.=line
      break
    endif
  endfor
  return l:cpath
endfunction "}}}


fun! s:create_fake_jar_and_index_file() "{{{
  call s:create_vimtempstuff_dir()
  call s:create_manifest()

  let curdir=getcwd()
  execute "lcd " . curdir . '/.vimtempstuff'

  let out=system(g:jar_command . " -cmf manifest ../.mvncp.jar ")
  echom out
  execute "lcd ". curdir


  if has('win32')
   call system('rmdir /Q /S .vimtempstuff')
  else
    call system('rmdir -rf .vimtempstuff')
  endif

  redraw!
endfunction "}}}

command! PrepareForMaven call s:create_fake_jar_and_index_file()


