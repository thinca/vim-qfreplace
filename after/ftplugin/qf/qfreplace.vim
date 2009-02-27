if !exists('b:undo_ftplugin')
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= '| execute "delcommand Qfreplace"'


command! -nargs=? -buffer Qfreplace call qfreplace#start(<q-args>)
