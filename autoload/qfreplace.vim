let s:save_cpo = &cpo
set cpo&vim

if !exists('g:qfreplace_bufopen_cmd')
  let g:qfreplace_bufopen_cmd = 'new'
endif

function! qfreplace#start()
  call s:openReplaceBuffer()
endfunction

function! s:openReplaceBuffer()
  let opened_p = 0
  if exists('b:qfreplace_bufnr')
    let win = bufwinnr(b:qfreplace_bufnr)
    if 0 <= win
      execute win . 'wincmd w'
      let opened_p = !0
    endif
  endif
  if !opened_p
    execute g:qfreplace_bufopen_cmd '[qfreplace]'
    setlocal noswapfile bufhidden=hide buftype=acwrite
    call setbufvar('#', 'qfreplace_bufnr', bufnr('%'))
  endif

  let b:qfreplace_orig_qflist = getqflist()
  for e in b:qfreplace_orig_qflist
    call append(line('$'), e.text)
  endfor
  1 delete _
  setlocal nomodified

  autocmd BufWriteCmd <buffer> nested call s:doReplace()
endfunction

function! s:doReplace()
  let qf = b:qfreplace_orig_qflist " for easily access
  if line('$') != len(qf)
    throw printf('Illegal edit: line number was changed from %d to %d.',
          \ len(qf), line('$'))
  endif

  setlocal nomodified
  let bufnr = bufnr('%')
  let replace = getline(0, '$')
  let i = 0
  for e in qf
    execute 'edit' '#' . e.bufnr
    call setline(e.lnum, replace[i])
    update
    let i += 1
  endfor
  execute 'edit' '#' . bufnr
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

finish
