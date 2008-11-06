if !exists('b:undo_ftplugin')
  let b:undo_ftplugin = ''
endif




nnoremap <buffer> <silent> <Plug>qfreplace :<C-u>call qfreplace#start()<CR>

if !hasmapto('<Plug>qfreplace')
  silent! nmap <unique> <buffer> r <Plug>qfreplace
  let b:undo_ftplugin .= '| execute "nunmap <buffer> r"'
endif
