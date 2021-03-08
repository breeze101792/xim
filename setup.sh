#!/bin/bash
IDE_ROOT=`pwd`
VIM_ROOT=$HOME"/.vim"
VIM_BAK_ROOT=$IDE_ROOT"/vim_bak_"$(date +%Y%m%d_%H%M%S)
function plugin()
{
    echo "Setup plugins"
    # Youcompleteme vim 7.4 85bdbdb206bf51a0d084816e6347a75e50f19ec8
    cd ${VIM_ROOT}/bundle
    git clone https://github.com/ycm-core/YouCompleteMe.git
    cd YouCompleteMe
    git submodule update --init --recursive
    ./install.py --all
}
function setup()
{
    echo $VIM_BAK_ROOT
    if [ -d $VIM_ROOT ]
    then
        mv $VIM_ROOT $VIM_BAK_ROOT
    fi
    # if [ -e $HOME/.vimrc ]
    # then
    #     mv $HOME/.vimrc $VIM_BAK_ROOT/
    # fi
    if cat $HOME/.vimrc |grep "vim-ide.vim" > /dev/null
    then
        echo "Vim-ide exist."
    else
        echo "echo vim-ide to vimrc"
        touch ~/.vimrc
        echo "so ~/.vim/vim-ide.vim" >> ~/.vimrc
    fi

    mkdir $VIM_ROOT
    ln -sf $IDE_ROOT/vim-ide.vim $VIM_ROOT/
    ln -sf $IDE_ROOT/scripts $VIM_ROOT/vim-ide
    mkdir -p $VIM_ROOT/bundle/
    ln -sf $IDE_ROOT/plugins/* $VIM_ROOT/bundle/

    pushd $VIM_ROOT > /dev/null
    {
        ln -sf bundle/vim-pathogen/autoload .
    }
    popd > /dev/null
    echo "Don't forget to init submodule."
}
setup
