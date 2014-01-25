if !exists("g:ackprg")
	let g:ackprg=""
endif

fun! <SID>Which(cmd)
	let l:path=substitute(system('which ' . a:cmd), '\n', '', 'g')
	if v:shell_error==0
		return l:path
	endif
	return ""
endfun

if empty(g:ackprg)
	let g:ackprg=<SID>Which('ack-grep')
endif
if empty(g:ackprg)
	let g:ackprg=<SID>Which('ack')
endif
if empty(g:ackprg)
	echo('found no g:ackprg')
else
	let &grepprg=g:ackprg . ' --column'
	set grepformat=%f:%l:%c:%m
endif
