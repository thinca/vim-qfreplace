if exists('b:did_ftplugin_qfreplace')
  finish
endif
let b:did_ftplugin_qfreplace = 1

nnoremap <buffer> <silent> <Plug>qfreplace :<C-u>call qfreplace#start()<CR>

if !hasmapto('<Plug>qfreplace')
  silent! nmap <unique> <buffer> r <Plug>qfreplace
endif

