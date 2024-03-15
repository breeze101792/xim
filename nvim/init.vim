set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

luafile ~/.config/nvim/lua/nvimide.lua

" -------------------------------------------
"Lua  Reload
" -------------------------------------------
command! LuaReload call LuaReload()

func! LuaReload()
    luafile ~/.config/nvim/lua/nvimide.lua
endfunc
