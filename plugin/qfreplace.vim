" Perform the replacement in quickfix.
" Version: 0.5
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_qfreplace')
  finish
endif
let g:loaded_qfreplace = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? Qfreplace call qfreplace#start(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
