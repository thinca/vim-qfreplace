" Perform the replacement in quickfix.
" Version: 0.5
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

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
  for e in s:get_effectual_lines(b:qfreplace_orig_qflist)
    call append(line('$'), s:chomp(e.text))
  endfor
  1 delete _
  setlocal nomodified
endfunction

function! s:do_replace()
  let qf = s:get_effectual_lines(b:qfreplace_orig_qflist)
  if line('$') != len(qf)
    let tp = 'qfreplace: Illegal edit: line number was changed from %d to %d.'
    call s:echoerr(printf(tp, len(qf), line('$')))
    return
  endif

  setlocal nomodified
  let update = 'update' . (v:cmdbang ? '!' : '')
  let bufnr = bufnr('%')
  let new_text_lines = getline(1, '$')
  let i = 0
  let prev_bufnr = -1
  for e in qf
    let new_text = new_text_lines[i]
    let i += 1
    if e.text ==# new_text
      continue
    endif
    if prev_bufnr != e.bufnr
      if prev_bufnr != -1
        execute update
      endif
      execute e.bufnr 'buffer'
    endif
    if e.text !=# new_text
      if getline(e.lnum) !=# s:chomp(e.text)
        call s:echoerr(printf(
        \  'qfreplace: Original text has changed: %s:%d',
        \   bufname(e.bufnr), e.lnum))
      else
        call setline(e.lnum, new_text)
        let e.text = new_text
      endif
    endif
    let prev_bufnr = e.bufnr
  endfor
  execute update
  execute bufnr 'buffer'
  call setqflist(b:qfreplace_orig_qflist, 'r')
endfunction

function! s:get_effectual_lines(qf)
  return filter(copy(a:qf), 's:is_effectual_line(v:val)')
endfunction

function! s:is_effectual_line(qf_line)
  return get(a:qf_line, "bufnr", 0)
endfunction

function! s:echoerr(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

function! s:chomp(str)
  return matchstr(a:str, '^.\{-}\ze\r\?$')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

finish
