if !exists("g:findprg")
	let g:findprg=""
endif

fun! <SID>Find(...)
	copen
	set errorformat=%f
	cexpr system(g:findprg . ' ' . join(a:000))
endfun

fun! <SID>Which(cmd)
	let l:path=substitute(system('which ' . a:cmd), '\n', '', 'g')
	if v:shell_error==0
		return l:path
	endif
	return ""
endfun

if empty(g:findprg)
	let g:findprg=<SID>Which('gfind')
endif
if empty(g:findprg)
	let g:findprg=<SID>Which('find')
endif
if empty(g:findprg)
	echo('found no g:findprg')
else
	command! -nargs=* Find call <SID>Find(<f-args>)
endif
