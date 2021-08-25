" Source needed scripts
if version >= 704
    so ~/.vim/vim-ide/Settings.vim
    so ~/.vim/vim-ide/Functions.vim
    so ~/.vim/vim-ide/Environment.vim
    so ~/.vim/vim-ide/Plugins.vim
    so ~/.vim/vim-ide/PluginsConfig.vim
    so ~/.vim/vim-ide/KeyMaps.vim
    so ~/.vim/vim-ide/Lab.vim
    so ~/.vim/vim-ide/Template.vim
elseif version < 704
    so ~/.vim/vim-ide/Settings.vim
    so ~/.vim/vim-ide/KeyMaps.vim
endif
