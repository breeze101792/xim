" Source needed scripts
if !empty(glob("~/.vim/Config_Customize.vim"))
    so ~/.vim/Config_Customize.vim
endif

if version >= 704
    so ~/.vim/vim-ide/Config.vim
    so ~/.vim/vim-ide/Environment.vim
    so ~/.vim/vim-ide/Settings.vim
    so ~/.vim/vim-ide/Functions.vim
    so ~/.vim/vim-ide/CodeEnhance.vim
    so ~/.vim/vim-ide/Plugins.vim
    so ~/.vim/vim-ide/PluginsConfig.vim
    so ~/.vim/vim-ide/KeyMaps.vim
    so ~/.vim/vim-ide/Lab.vim
    so ~/.vim/vim-ide/Template.vim
elseif version < 704
    so ~/.vim/vim-ide/Config.vim
    so ~/.vim/vim-ide/Settings.vim
    so ~/.vim/vim-ide/KeyMaps.vim
endif
