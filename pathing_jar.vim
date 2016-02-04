let g:maven_command='mvn -gs C:/java/.settings.xml'
let g:jar_command='C:/java/jdk1.7.0_79/bin/jar'


fun! s:create_vimtempstuff_dir() "{{{
  if !isdirectory('.vimtempstuff')
    call mkdir('.vimtempstuff', 'p')
  endif
  
  echo "directory created"
endfunction "}}}

fun! s:create_manifest_contents() "{{{
  let l:classpath_str=system(g:maven_command . ' dependency:build-classpath')
  
  let lines = split(l:classpath_str, '\n')
  
  let cpath='Class-Path: '
  for line in lines
    if line =~ 'jar$'
      let cpath.=line
      break
    endif
  endfor
  
  if has('win32')
    let cpath=substitute(cpath, ';', ' ', 'g')
    let cpath=substitute(cpath, '\v([A-Z]):\\', '/\1:/', 'g')
    let cpath=substitute(cpath, '\\', '/', 'g')
  else
    let cpath=substitute(cpath, ':', ' ')
    let cpath=substitute(cpath, '\v^\ze/| \ze/', 'file://', 'g')
  endif
  
  let cpath=substitute(cpath, '\v\ze(.{69})+$', ' ','g')
  let cpath_list=split(cpath, '\v\ze(.{70})+$')
  
  let curdir=getcwd()
  
  let data=[g:manifest_dict['archiver_version'],
        \ g:manifest_dict['version'],
        \ g:manifest_dict['jdk'],
        \ g:manifest_dict['by']]
  
  call writefile(data, '.vimtempstuff/manifest')
  call writefile(cpath_list, '.vimtempstuff/manifest', 'a')

  return l:classpath_str
endfunction "}}}


fun! s:create_fake_jar_and_index_file() "{{{
  call s:create_vimtempstuff_dir()
  let l:classpath = s:create_manifest_contents()
  
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
  echom 'directory deleted'
  
  redraw!
endfunction "}}}

command! PrepareForMaven call s:create_fake_jar_and_index_file()
