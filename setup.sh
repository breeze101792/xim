#!/bin/bash
IDE_ROOT=`pwd`
VIM_ROOT=$HOME"/.vim"
VIM_BAK_ROOT=$IDE_ROOT"/vim_bak_"$(date +%Y%m%d_%H%M%S)
function ycm()
{
    echo "Setup plugins"
    # Youcompleteme vim 7.4 85bdbdb206bf51a0d084816e6347a75e50f19ec8
    cd ${VIM_ROOT}/bundle
    git clone https://github.com/ycm-core/YouCompleteMe.git
    cd YouCompleteMe
    git submodule update --init --recursive
    ./install.py --all
}
function ccglue()
{
    local ccglue_url="https://versaweb.dl.sourceforge.net/project/ccglue/binaries/ccglue-x86-linux-elf-glib-2.0-v_0.1.2.tar.gz"
    mkdir -p ${IDE_ROOT}/tools
    mkdir -p ${IDE_ROOT}/tmp
    cd ${IDE_ROOT}/tmp/
    curl --insecure ${ccglue_url} -o ccglue.tar.gz
    tar xvzf ccglue.tar.gz
    cp release-0.1.2/bin/ccglue ${IDE_ROOT}/tools
    rm -rf -p ${IDE_ROOT}/tmp
    echo "Please do and add ~/bin to your patch"
    echo "cp tools/* ~/.bin"
}
function setup()
{
    local flag_ln_all_plugins=true
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

    if [ ${flag_ln_all_plugins} = true ]
    then
        ln -sf $IDE_ROOT/plugins $VIM_ROOT/bundle
    else
        mkdir -p $VIM_ROOT/bundle/
        ln -sf $IDE_ROOT/plugins/* $VIM_ROOT/bundle/
    fi

    mkdir -p $VIM_ROOT/autoload/
    ln -sf $VIM_ROOT/bundle/vim-pathogen/autoload/pathogen.vim $VIM_ROOT/autoload/

    mkdir -p $VIM_ROOT/after/

    echo "Don't forget to init submodule."
}
function setup_after()
{
    echo "Setup After with plugins"
    cd $IDE_ROOT/plugins
    for each_plugin in $(ls)
    do
        # echo ${each_plugin}
        cd $IDE_ROOT/plugins
        if [ -d "${each_plugin}/after" ]
        then
            echo Install ${each_plugin}/after to vim
            ln -sf ${each_plugin}/after/* ${VIM_ROOT}/after
        fi
    done
}
function main()
{
    local flag_setup="n"
    local flag_ccglue="n"
    local flag_ycm="n"
    while [[ "$#" != 0 ]]
    do
        case $1 in
            -s|--setup)
                flag_setup="y"
                ;;
            -c|--ccglue)
                flag_ccglue="y"
                ;;
            -y|--ycm)
                flag_ycm="y"
                ;;
            -h|--help)
                echo "VIM IDE Setup Tool"
                printf  "    %s ->%s \n" "-s|--setup" "Setup up vim ide"
                printf  "    %s ->%s \n" "-c|--ccglue)" "Download ccglue"
                printf  "    %s ->%s \n" "-y|--ycm" "Download ycm plugin"
                return 0
                ;;
            *)
                echo "Unknown Args. Please do ./setup.sh -h"
                return 1
                ;;
        esac
        shift 1
    done
    if [ "${flag_setup}" = "y" ]
    then
        setup
        setup_after
    fi
    if [ "${flag_ccglue}" = "y" ]
    then
        ccglue
    fi
    if [ "${flag_ycm}" = "y" ]
    then
        ycm
    fi
}
main $@
