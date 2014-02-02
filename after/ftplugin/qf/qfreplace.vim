" Perform the replacement in quickfix.
" Version: 0.3
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if !exists('b:undo_ftplugin')
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= '| execute "delcommand Qfreplace"'


command! -nargs=? -buffer Qfreplace call qfreplace#start(<q-args>)
