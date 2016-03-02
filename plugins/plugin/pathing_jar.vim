let g:maven_command='mvn -gs C:/java/.settings.xml'
let g:jar_command='C:/java/jdk1.7.0_79/bin/jar'
let g:javac_command_test='C:/java/jdk1.7.0_79/bin/javac -cp ".mvncp.jar;target/test-classes;target/classes" -sourcepath "src/main/java;src/test/java" -d "target/test-classes"'
let g:javac_command_main='C:/java/jdk1.7.0_79/bin/javac -cp ".mvncp.jar;target/test-classes;target/classes" -sourcepath "src/main/java" -d "target/classes"'
let g:junit_command='C:/java/jdk1.7.0_79/bin/java -cp ".mvncp.jar;target/classes;target/test-classes" org.junit.runner.JUnitCore'

let g:manifest_dict = {
      \ 'archiver_version': "Archiver-Version: javavimmesss archiver",
      \ 'version': "Manifest-Version: 1.0",
      \ 'by': "Created-By: vimplugin",
      \ 'extra': 'Main-Class: org.junit.core.JUnitCore'
      \ }


fun! s:create_vimtempstuff_dir() "{{{
  if !isdirectory('.vimjavastuff')
    call mkdir('.vimjavastuff', 'p')
  endif

  echo "directory created"
endfunction "}}}

fun! s:create_manifest() "{{{

  let data=[g:manifest_dict['archiver_version'],
        \ g:manifest_dict['version'],
        \ g:manifest_dict['by']]

  let l:classpath_str = s:discard_non_classpath_lines(split(system(g:maven_command . ' dependency:build-classpath'), '\n'))
  let cpath_list = s:format_cpath_lines(l:classpath_str)

  call writefile(data, '.vimjavastuff/manifest')
  call writefile(cpath_list, '.vimjavastuff/manifest', 'a')
  call writefile(filter(split(l:classpath_str, '\v(<[A-Z]|[A-Z])@<![:;]'), 'v:val =~ "jar$"')
        \ , '.vimjavastuff/jars_on_cp')

endfunction "}}}

fun! s:extract_classpath_lines(classpath_str) "{{{
  let l:cpath=s:discard_non_classpath_lines(split(a:classpath_str, '\n'))
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
  let list = split(l:cpath, '\v\ze(.{66})+$')
  return list

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
  execute "lcd " . curdir . '/.vimjavastuff'

  let out=system(g:jar_command . " -cmf manifest ../.mvncp.jar ")
  echom out
  execute "lcd ". curdir

  redraw!
endfunction "}}}


fun! s:get_classname() "{{{
  let l:package = substitute(getline(searchpos("^package", 'bn')[0]), '\vpackage |;|\s+', '', 'g')
  let l:classname = expand('%:t:r')
  return l:package . '.' . l:classname
endfunction "}}}


fun! s:exec_junit() "{{{
  let @+ = ''
  let l:str_output = system(g:junit_command . ' ' . s:get_classname())
  let @+ .= l:str_output
endfunction "}}}

fun! s:compile_this() "{{{
  let l:command = g:javac_command_main
  if expand("%:p") =~ 'src/test'
    let l:command= g:javac_command_test
  endif
  let l:str_output = system(l:command . ' ' . expand('%'))
  echom v:shell_error
endfunction "}}}

fun! s:echoerror(whaa) "{{{
  call s:echoformated("Error", a:whaa)
endfunction "}}}

fun! s:echonotcompile(msg) "{{{
    hi WarnGroup ctermfg=white ctermbg=15 guifg=Black guibg=DarkYellow
    call s:echoformated("WarnGroup", a:msg)
endfunction "}}}

fun! s:echosuccess(wohoo) "{{{
  hi SuccessGroup ctermfg=white ctermbg=DarkGreen guifg=white guibg=DarkGreen
  call s:echoformated("SuccessGroup", a:wohoo)
endfunction "}}}

fun! s:echoformated(format, message) "{{{
  call s:formatmessage(a:format, a:message)
  call s:clear_echo_output()
endfunction "}}}

fun! s:formatmessage(format, message) "{{{
  let l:numcols = &columns
  let l:iterations=l:numcols - 2 - len(a:message)
  execute "echohl " . a:format
  echon a:message . repeat(' ', l:iterations)
  echohl Normal
endfunction "}}}

fun! s:clear_echo_output() "{{{
  sleep 150m
  for i in range(&cmdheight)
    echo ' '
  endfor
  redraw
endfunction "}}}

fun! s:total_classes() "{{{
  let l:file = '.vimjavastuff/jars_on_cp'
  if !filereadable(l:file)
    PrepareForMaven
  endif
  let l:lines = readfile(l:file)
  let l:count=0
  for l:line in l:lines
    let l:count += len(filter(split(system(g:jar_command . ' tf '. l:line), '\n'), 'v:val =~ "\.class$"'))
  endfor
  echom 'a total of ' . l:count . ' lines'
endfunction "}}}

command! PrepareForMaven call s:create_fake_jar_and_index_file()
command! Test call s:exec_junit()
command! C execute "w" | call s:compile_this()
command! Scream call s:echoerror('gaaaaaaa!!!!')
command! Woho call s:echosuccess('Woho!')
command! Ouch call s:echonotcompile('Ouch!')
command! CountClasses call s:total_classes()


