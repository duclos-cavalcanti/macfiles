" Moonspector - Lua debugging plugin
" Auto-setup when plugin loads

if exists('g:loaded_moonspector')
  finish
endif

let g:loaded_moonspector = 1

lua require('moonspector').setup()
