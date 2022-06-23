#!/bin/bash
IDE_ROOT=`pwd`
VIM_ROOT=$HOME"/.vim"
VIM_BAK_ROOT=$IDE_ROOT"/vim_bak_"$(date +%Y%m%d_%H%M%S)
function plugins_check()
{
    local var_check="pass"
    for each_plugin in $(ls ${IDE_ROOT}/plugins)
    do
        # echo ${each_plugin}
        if [ "${each_plugin}" != "vim-plug" ] && ! cat ${IDE_ROOT}/scripts/Plugins.vim | grep ${each_plugin} > /dev/null
        then
            echo Plugin ${each_plugin} not found in Plugins.vim
            var_check="fail"
        fi
    done
    echo "Check plugins: ${var_check}"
}
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
    local target_file="ccglue.tgz"
    mkdir -p ${IDE_ROOT}/tools
    mkdir -p ${IDE_ROOT}/tmp
    cd ${IDE_ROOT}/tmp/
    curl --insecure ${ccglue_url} -o "${target_file}"
    if file "${target_file}" | grep gzip
    then
        tar xvzf "${target_file}"
    else
        echo "Fail to download src code, will try with wget."
        rm "${target_file}"
        aria2c "${ccglue_url}" -o "${target_file}"
        tar xvzf "${target_file}"
    fi
    cp release-0.1.2/bin/ccglue ${IDE_ROOT}/tools
    rm -rf ${IDE_ROOT}/tmp
    echo "Please do and add ~/bin to your patch"
    echo "cp tools/* ~/.bin"
}
function setup()
{
    local flag_ln_all_plugins=true
    echo $VIM_BAK_ROOT
    if [ -d $VIM_ROOT ]
    then
        cp -rf $VIM_ROOT $VIM_BAK_ROOT
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

    test -d $VIM_ROOT || mkdir $VIM_ROOT
    ln -sf $IDE_ROOT/vim-ide.vim $VIM_ROOT/
    ln -sf $IDE_ROOT/scripts $VIM_ROOT/vim-ide
    ln -sf $IDE_ROOT/tools $VIM_ROOT/tools

    if [ ${flag_ln_all_plugins} = true ]
    then
        ln -sf $IDE_ROOT/plugins $VIM_ROOT/plugins
    else
        mkdir -p $VIM_ROOT/plugins/
        ln -sf $IDE_ROOT/plugins/* $VIM_ROOT/plugins/
    fi

    mkdir -p $VIM_ROOT/autoload/
    mkdir -p $VIM_ROOT/colors/
    mkdir -p $VIM_ROOT/swp/
    ln -sf $VIM_ROOT/plugins/vim-plug/plug.vim $VIM_ROOT/autoload/
    setup_cus_config

    echo "Don't forget to init submodule."

}
function setup_cus_config()
{
    touch $VIM_ROOT/Config_Customize.vim
    for each_config in $(cat scripts/Config.vim | grep let | cut -d ':' -f 2 | cut -d '=' -f 1)
    do
        # echo "Checking ${each_config}"
        if cat $VIM_ROOT/Config_Customize.vim | grep ${each_config} > /dev/null
        then
            echo "Skip config ${each_config}, already exist"
        else
            echo "Adding config ${each_config}"
            cat scripts/Config.vim | grep ${each_config} | grep "\"n\"" | sed 's/get.*/"n"/g' >> $VIM_ROOT/Config_Customize.vim
            cat scripts/Config.vim | grep ${each_config} | grep "\"y\"" | sed 's/get.*/"y"/g' >> $VIM_ROOT/Config_Customize.vim
        fi
    done
}
function setup_after()
{
    echo "Setup After with plugins"
    mkdir -p $VIM_ROOT/after/
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
    local flag_plugins="n"
    local flag_temp_config="n"
    while [[ "$#" != 0 ]]
    do
        case $1 in
            -s|--setup)
                flag_setup="y"
                ;;
            -p|--plugins)
                flag_plugins="y"
                ;;
            -c|--ccglue)
                flag_ccglue="y"
                ;;
            -y|--ycm)
                flag_ycm="y"
                ;;
            -t|--temp-config)
                flag_temp_config="y"
                ;;
            -h|--help)
                echo "VIM IDE Setup Tool"
                printf  "    %s ->%s \n" "-s|--setup" "Setup up vim ide"
                printf  "    %s ->%s \n" "-p|--plugins)" "Check plugins with Plugins.vim"
                printf  "    %s ->%s \n" "-c|--ccglue)" "Download ccglue"
                printf  "    %s ->%s \n" "-y|--ycm" "Download ycm plugin"
                printf  "    %s ->%s \n" "-t|--temp-config" "Setup temp config"
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
        # setup_after
    fi
    if [ "${flag_plugins}" = "y" ]
    then
        plugins_check
    fi
    if [ "${flag_ccglue}" = "y" ]
    then
        ccglue
    fi
    if [ "${flag_ycm}" = "y" ]
    then
        ycm
    fi
    if [ "${flag_temp_config}" = "y" ]
    then
        setup_cus_config
    fi

}
main $@
