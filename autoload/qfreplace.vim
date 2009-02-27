" Perform the replacement in quickfix.
" Version: 0.3
" Author : thinca <http://d.hatena.ne.jp/thinca/>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim

let s:qfreplace_bufnr = -1

function! qfreplace#start(cmd)
  call s:open_replace_window(empty(a:cmd) ? 'split' : a:cmd)
endfunction

function! s:open_replace_window(cmd)
  if bufexists(s:qfreplace_bufnr)
    let win = bufwinnr(s:qfreplace_bufnr)
    if 0 <= win
      execute win . 'wincmd w'
    else
      execute a:cmd
      execute s:qfreplace_bufnr 'buffer'
    endif
  else
    execute a:cmd
    enew
    setlocal noswapfile bufhidden=hide buftype=acwrite
    file `='[qfreplace]'`
    autocmd BufWriteCmd <buffer> nested call s:do_replace()
    setlocal filetype=qfreplace
    let s:qfreplace_bufnr = bufnr('%')
  endif

  % delete _
  let b:qfreplace_orig_qflist = getqflist()
  for e in b:qfreplace_orig_qflist
    call append(line('$'), e.text)
  endfor
  1 delete _
  setlocal nomodified
endfunction

function! s:do_replace()
  let qf = b:qfreplace_orig_qflist " for easily access
  if line('$') != len(qf)
    throw printf('Illegal edit: line number was changed from %d to %d.',
          \ len(qf), line('$'))
  endif

  setlocal nomodified
  let update = 'update' . (v:cmdbang ? '!' : '')
  let bufnr = bufnr('%')
  let replace = getline(0, '$')
  let i = 0
  let prev_bufnr = -1
  for e in qf
    if prev_bufnr != e.bufnr
      if prev_bufnr != -1
        execute update
      endif
      execute e.bufnr 'buffer'
    endif
    if e.text != replace[i]
      if getline(e.lnum) != e.text
        echoerr printf('Original text are changed: %s:%d', bufname(e.bufnr),
          \ e.lnum)
      else
        call setline(e.lnum, replace[i])
        let e.text = replace[i]
      endif
    endif
    let prev_bufnr = e.bufnr
    let i += 1
  endfor
  execute update
  execute bufnr 'buffer'
  call setqflist(qf, 'r')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

finish
