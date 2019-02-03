#!/bin/bash
IDE_ROOT=`pwd`
VIM_ROOT=$HOME"/.vim"
VIM_BAK_ROOT=$IDE_ROOT"/vim_bak_"$(date +%Y%m%d_%H%M%S)
function setup()
{
    echo $VIM_BAK_ROOT
    if [ -d $VIM_ROOT ]
    then
        mv $VIM_ROOT $VIM_BAK_ROOT
    fi
    if [ -e $HOME/.vimrc ]
    then
        mv $HOME/.vimrc $VIM_BAK_ROOT/
    fi

    mkdir $VIM_ROOT
    ln -sf $IDE_ROOT/plugins $VIM_ROOT/bundle
    pushd $VIM_ROOT > /dev/null
    {
        ln -sf bundle/vim-pathogen/autoload .
    }
    popd > /dev/null
    ln -sf $IDE_ROOT/vim-ide.vim $HOME/.vimrc
}
setup
