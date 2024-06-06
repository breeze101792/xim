#!/bin/bash
###########################################################
## DEF
###########################################################
export DEF_COLOR_RED='\033[0;31m'
export DEF_COLOR_YELLOW='\033[0;33m'
export DEF_COLOR_GREEN='\033[0;32m'
export DEF_COLOR_NORMAL='\033[0m'

###########################################################
## Vars
###########################################################
export VAR_SCRIPT_NAME="$(basename ${BASH_SOURCE[0]%=.})"
export VAR_CPU_CNT=$(nproc --all)

###########################################################
## Options
###########################################################
export OPTION_VERBOSE=false

###########################################################
## Path
###########################################################
export PATH_ROOT="$(realpath $(dirname ${BASH_SOURCE[0]}))"
export PATH_IDE_ROOT="${PATH_ROOT}"
export PATH_LOCAL_VIM_ROOT=""
# export PATH_VIM_BACKUP=${PATH_LOCAL_VIM_ROOT}"/backup/backup_"$(date +%Y%m%d_%H%M%S)
export PATH_VIM_BACKUP=""

export PATH_CENTRAL_VIM_CACHE=${HOME}"/.vim"

###########################################################
## Utils Functions
###########################################################
fPrintHeader()
{
    local msg=${1}
    printf "###########################################################\n"
    printf "###########################################################\n"
    printf "##  %- $((60-4-${#msg}))s  ##\n" "${msg}"
    printf "###########################################################\n"
    printf "###########################################################\n"
    printf ""
}
fErrControl()
{
    local ret_var=$?
    local func_name=${1}
    local line_num=${2}
    if [[ ${ret_var} == 0 ]]
    then
        return ${ret_var}
    else
        echo ${func_name} ${line_num}
        exit ${ret_var}
    fi
}
fHelp()
{
    echo "${VAR_SCRIPT_NAME}"
    echo "[Example]"
    printf "    %s\n" "run test: .sh -a"
    echo "[Options]"
    printf "    %- 16s\t%s\n" "-s|--setup" "Setup vim. default vim."
    printf "    %- 16s\t%s\n" "-n|--nvim" "Specify instance. nvim"
    printf "    %- 16s\t%s\n" "-c|--config" "Generate config file"
    printf "    %- 16s\t%s\n" "-l|--lite" "Setup litevim."
    printf "    %- 16s\t%s\n" "-i|--instance" "Specify instance. vim/nvim/all"
    printf "    %- 16s\t%s\n" "-a|--all" "Specify instance. all"
    printf "    %- 16s\t%s\n" "-h|--help" "Print helping"
}
fInfo()
{
    local var_title_pading""

    fPrintHeader ${FUNCNAME[0]}
    printf "###########################################################\n"
    printf "##  Vars\n"
    printf "###########################################################\n"
    printf "##    %s\t: %- 16s\n" "Script" "${VAR_SCRIPT_NAME}"
    printf "###########################################################\n"
    printf "##  Path\n"
    printf "###########################################################\n"
    printf "##    %s\t: %- 16s\n" "Working Path" "${PATH_ROOT}"
    printf "###########################################################\n"
    printf "##  Options\n"
    printf "###########################################################\n"
    printf "##    %s\t: %- 16s\n" "Verbose" "${OPTION_VERBOSE}"
    printf "###########################################################\n"
}
fSoftLink()
{
    local var_src_path=$1
    local var_dst_path=$2

    if test -L "${var_dst_path}"
    then
        echo -e "${DEF_COLOR_YELLOW} Ignore links, (${var_src_path} to ${var_dst_path})${DEF_COLOR_NORMAL}"
        return 0
    elif test -e "${var_dst_path}"
    then
        echo -e "${DEF_COLOR_RED} File exist & not symbolic link (${var_src_path} to ${var_dst_path})${DEF_COLOR_NORMAL}"
        return 1
    else
        echo "Link ${var_src_path} to ${var_dst_path}."
        ln -s ${var_src_path} ${var_dst_path}
        return 0
    fi
}
fSleepSeconds()
{
    local var_sleep_cnt=0
    if [ $# = 1 ]
    then
        var_sleep_cnt=${1}
    else
        return -1
    fi
    # only sleep for seconds
    for each_idx in $(seq 1 $var_sleep_cnt)
    do
        printf "\rSleeping (%d/%d)" ${each_idx} ${var_sleep_cnt}
        sleep 1
    done;
    printf "\nwakeup from sleep(${var_sleep_cnt})\n"
    return 1
}
fEval()
{
    local var_commands=0
    if [[ $# = 1 ]]
    then
        var_commands=${1}
    elif [[ $# > 1 ]]
    then
        if [[ "${1}" = "-s" ]]
        then
            shift 1
            var_commands="sudo ${@}"
        else
            var_commands=${@}
        fi
    else
        return -1
    fi
    echo -e "Executing: ${DEF_COLOR_YELLOW}${var_commands}${DEF_COLOR_NORMAL} "
    ${var_commands}
    return $?
}
###########################################################
## Functions
###########################################################
## Legacy
###########################################################

function fycm()
{
    echo "Setup plugins"
    # Youcompleteme vim 7.4 85bdbdb206bf51a0d084816e6347a75e50f19ec8
    cd ${PATH_LOCAL_VIM_ROOT}/bundle
    git clone https://github.com/ycm-core/YouCompleteMe.git
    cd YouCompleteMe
    git submodule update --init --recursive
    ./install.py --all
}
function fPlugins_check()
{
    local var_check="pass"
    local var_plugin_file="${PATH_IDE_ROOT}/scripts/plugin/Plugin.vim"
    # check vim
    for each_plugin in $(ls ${PATH_IDE_ROOT}/plugins)
    do
        # echo ${each_plugin}
        if [ "${each_plugin}" != "vim-plug" ] && ! cat ${var_plugin_file} | grep "${each_plugin}"> /dev/null \
            && ! echo "${each_plugin}" |grep nvim > /dev/null
        then
            echo Plugin ${each_plugin} not found in ${var_plugin_file}
            var_check="fail"
        fi
    done
    echo "Check vim plugins: ${var_check}"

    local var_check="pass"
    local var_plugin_file="${PATH_IDE_ROOT}/nvim/lua/nvimide/plugin/plugin.lua"
    # check nvim
    for each_plugin in $(ls ${PATH_IDE_ROOT}/plugins)
    do
        # echo ${each_plugin}
        if [ "${each_plugin}" != "vim-plug" ] && ! cat ${var_plugin_file} | grep "${each_plugin}"> /dev/null
        then
            echo Plugin ${each_plugin} not found in ${var_plugin_file}
            var_check="fail"
        fi
    done
    echo "Check nvim plugins: ${var_check}"
}
function fCompre_colorscheme()
{
    # bash colorscheme_check.sh ~/.vim/colors/autogen.vim plugins/vim-ide/colors/afterglow_lab.vim
    local var_ref_scheme=${1}
    local var_target_scheme=${2}
    # for unlink target
    for each_label in $(cat ${var_ref_scheme} | grep hi | grep -v link | cut -d ' ' -f 2)
    do
        # echo ${each_label}
        if ! cat ${var_target_scheme} | grep ${each_label} > /dev/null
        then
            echo "${each_label} is missing"
        fi
    done

    # for link target
    for each_label in $(cat ${var_ref_scheme} | grep hi | grep link | cut -d ' ' -f 3)
    do
        # echo ${each_label}
        if ! cat ${var_target_scheme} | grep ${each_label} > /dev/null
        then
            echo "link ${each_label} is missing"
        fi
    done

}
function fCcglue()
{
    local ccglue_url="https://versaweb.dl.sourceforge.net/project/ccglue/binaries/ccglue-x86-linux-elf-glib-2.0-v_0.1.2.tar.gz"
    local target_file="ccglue.tgz"
    # or download it from git@github.com:breeze101792/ccglue.git
    mkdir -p ${PATH_IDE_ROOT}/bin
    mkdir -p ${PATH_IDE_ROOT}/tmp
    cd ${PATH_IDE_ROOT}/tmp/
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
    cp release-0.1.2/bin/ccglue ${PATH_IDE_ROOT}/bin
    rm -rf ${PATH_IDE_ROOT}/tmp
    echo "Please do and add ~/bin to your patch"
    echo "cp tools/* ~/.bin"
}
## Setup Functions
###########################################################
function fexample()
{
    fPrintHeader ${FUNCNAME[0]}

}
function setup_after()
{
    echo "Setup After with plugins"
    mkdir -p ${PATH_LOCAL_VIM_ROOT}/after/
    cd ${PATH_IDE_ROOT}/plugins
    for each_plugin in $(ls)
    do
        # echo ${each_plugin}
        cd ${PATH_IDE_ROOT}/plugins
        if [ -d "${each_plugin}/after" ]
        then
            echo Install ${each_plugin}/after to vim
            ln -sf ${each_plugin}/after/* ${PATH_LOCAL_VIM_ROOT}/after
        fi
    done
}
function fBackup()
{
    fPrintHeader ${FUNCNAME[0]}
    local var_backup_file=$@

    if [ -e "${var_backup_file}" ]
    then
        test -d ${PATH_VIM_BACKUP} || mkdir -p ${PATH_VIM_BACKUP}
        cp -rf ${var_backup_file} ${PATH_VIM_BACKUP}
    fi
}

function fSetupCusConfig()
{
    fPrintHeader ${FUNCNAME[0]}
    local path_central_cache="${PATH_CENTRAL_VIM_CACHE}"

    if test -f "${path_central_cache}/ConfigCustomize.vim"
    then
        # echo "Config exist. ${path_central_cache}/ConfigCustomize.vim"
        # return 0
        fBackup "${path_central_cache}/ConfigCustomize.vim"
    fi
    
    touch ${path_central_cache}/ConfigCustomize.vim
    for each_config in $(cat ${PATH_IDE_ROOT}/scripts/core/Config.vim | grep let |tr -s ' ' | cut -d ':' -f 2 | cut -d '=' -f 1 | sort | uniq)
    do
        echo "Checking ${each_config}"
        if cat ${path_central_cache}/ConfigCustomize.vim | grep ${each_config} > /dev/null
        then
            echo " - Skip config ${each_config}, already exist"
        else
            echo " - Adding config ${each_config}"
            cat ${PATH_IDE_ROOT}/scripts/core/Config.vim | grep ${each_config} | head -n 1 | grep "\"n\"" | sed 's/get.*/"n"/g' >> ${path_central_cache}/ConfigCustomize.vim
            cat ${PATH_IDE_ROOT}/scripts/core/Config.vim | grep ${each_config} | head -n 1 | grep "\"y\"" | sed 's/get.*/"y"/g' >> ${path_central_cache}/ConfigCustomize.vim
        fi
    done
}
function fSetupVim()
{
    fPrintHeader ${FUNCNAME[0]}
    local path_target_ins="${PATH_LOCAL_VIM_ROOT}"
    local var_default_ins="vim"
    local flag_ln_all_plugins=true
    local var_init_file="${HOME}/.vimrc"

    echo "#. Setup ${var_init_file}."
    if cat ${var_init_file} |grep "vim-ide.vim" > /dev/null
    then
        echo "Vim-ide exist."
    else
        test -f "${var_init_file}" && fBackup "${var_init_file}"
        echo "echo vim-ide to ${var_init_file}"
        touch ${var_init_file}
        echo "so ~/.vim/vim-ide.vim" >> ${var_init_file}
    fi

    test -L ${path_target_ins}/vim-ide.vim || ln -sf ${PATH_IDE_ROOT}/vim-ide.vim ${path_target_ins}/

    echo "#. Setup plugins."
    if [ ${flag_ln_all_plugins} = true ]
    then
        test -d ${path_target_ins}/plugins && rm -r ${path_target_ins}/plugins
        ln -sf ${PATH_IDE_ROOT}/plugins ${path_target_ins}/plugins
    else
        mkdir -p ${path_target_ins}/plugins/
        ln -sf ${PATH_IDE_ROOT}/plugins/* ${path_target_ins}/plugins/
    fi

    # setup plug.vim
    mkdir -p ${path_target_ins}/autoload/
    ln -sf ${path_target_ins}/plugins/vim-plug/plug.vim ${path_target_ins}/autoload/
}
function fSetupNeovim()
{
    fPrintHeader ${FUNCNAME[0]}
    local path_target_ins="${PATH_LOCAL_VIM_ROOT}"
    local var_nvim_root="${PATH_IDE_ROOT}/nvim"
    local var_init_file="init.lua"

    echo "#. Setup ${var_init_file}."
    if ! test -L "${path_target_ins}/${var_init_file}" && test -f "${path_target_ins}/${var_init_file}"
    then
        test -L "${path_target_ins}/${var_init_file}" || fBackup "${path_target_ins}/${var_init_file}"

        printf "$(realpath ${path_target_ins}/init.*) exist, do you want to override it?(y/N) "
        read user_input
        if [ ${user_input} = 'y' ] || [ ${user_input} = 'Y' ]
        then
            test -f "${path_target_ins}/${var_init_file}" && rm "${path_target_ins}/${var_init_file}"
        else
            return 0
        fi
    fi

    echo "#. Link nvim init file to ${path_target_ins}/"
    fSoftLink ${var_nvim_root}/${var_init_file} ${path_target_ins}/${var_init_file}
    fSoftLink ${var_nvim_root}/lua ${path_target_ins}/lua
}
function fSetup_lite()
{
    fPrintHeader ${FUNCNAME[0]}
    if test -f ${HOME}/.vimrc
    then
        echo "${HOME}/.vimrc exist, do you want to override it?(y/N)"
        read user_input
        if [ ${user_input} = 'y' ] || [ ${user_input} = 'Y' ]
        then
            cp -rf ${PATH_IDE_ROOT}/tools/vimlite.vim ${HOME}/.vimrc
        else
            return 0
        fi
    else
        echo "Copy vimlite to ${HOME}/.vimrc"
        cp -rf ${PATH_IDE_ROOT}/tools/vimlite.vim ${HOME}/.vimrc
    fi
}
function fSetup()
{
    fPrintHeader ${FUNCNAME[0]}
    local path_target_ins=""
    local path_central_cache="${PATH_CENTRAL_VIM_CACHE}"
    local var_instance=$1

    # Update config
    if [ "${var_instance}" = "vim" ]
    then
        export PATH_LOCAL_VIM_ROOT=${HOME}"/.vim"
    elif [ "${var_instance}" = "nvim" ]
    then
        export PATH_LOCAL_VIM_ROOT=${HOME}"/.config/nvim"
    fi
    export PATH_VIM_BACKUP=${PATH_LOCAL_VIM_ROOT}"/backup/backup_"$(date +%Y%m%d_%H%M%S)
    path_target_ins=$PATH_LOCAL_VIM_ROOT
    echo "#. Pre-config, ${path_target_ins}"

    # link ide path
    echo "#. Create/Link IDE scripts"
    test -d "${path_target_ins}"        || mkdir -p ${path_target_ins}
    test -d "${path_target_ins}/colors" || mkdir -p "${path_target_ins}/colors"
    fSoftLink ${PATH_IDE_ROOT}/tools ${path_target_ins}/tools
    fSoftLink ${PATH_IDE_ROOT}/scripts ${path_target_ins}/scripts
    fSoftLink ${PATH_IDE_ROOT}/plugins ${path_target_ins}/plugins

    echo "#. Setup instance"

    if [ "${var_instance}" = "vim" ]
    then
        fSetupVim "${var_instance}"; fErrControl ${FUNCNAME[0]} ${LINENO}
    elif [ "${var_instance}" = "nvim" ]
    then
        fSetupNeovim "${var_instance}"; fErrControl ${FUNCNAME[0]} ${LINENO}
    fi
    # Ignore after setup
    # setup_after

    echo "#. Setup Others."
    # FIXME, we are useing the same config/swp
    test -d ${path_central_cache}/swp || mkdir -p ${path_central_cache}/swp

    if [[ $(ls $PATH_IDE_ROOT/plugins/ | wc -l) -lt 5 ]]
    then
        echo -e "${DEF_COLOR_RED} Don't forget to init submodule.${DEF_COLOR_NORMAL}"
    fi
}
function fInstallScript()
{
    fPrintHeader ${FUNCNAME[0]}
    fSoftLink ${PATH_IDE_ROOT}/xim.sh ~/.usr/bin/xim
}

## Main Functions
###########################################################
function fMain()
{
    # fPrintHeader "Launch ${VAR_SCRIPT_NAME}"
    local flag_verbose=false
    local flag_setup=false
    local flag_setup_lite=false
    local flag_setup_config=false
    local flag_plugin_check=false
    local var_ins="vim"

    while [[ $# != 0 ]]
    do
        case $1 in
            # Options
            -s|--setup)
                flag_setup=true
                ;;
            -c|--config)
                flag_setup_config=true
                ;;
            -l|--lite)
                flag_setup_lite=true
                ;;
            -a|--all)
                flag_setup=true
                var_ins="all"
                ;;
            -n|--nvim)
                flag_setup=true
                var_ins="nvim"
                ;;
            -p|--plugin-check)
                flag_plugin_check=true
                ;;
            -i|--instance)
                flag_setup=true
                var_ins="$2"
                shift 1
                ;;
            -v|--verbose)
                flag_verbose=true
                ;;
            -h|--help)
                fHelp
                exit 0
                ;;
            *)
                echo "Unknown Options: ${1}"
                fHelp
                exit 1
                ;;
        esac
        shift 1
    done

    ## Download
    if [ ${flag_verbose} = true ]
    then
        OPTION_VERBOSE=y
        fInfo; fErrControl ${FUNCNAME[0]} ${LINENO}
    fi

    if [ ${flag_setup} = true ]
    then
        fBackup; fErrControl ${FUNCNAME[0]} ${LINENO}

        if [ "${var_ins}" = "vim" ]
        then
            fSetup "${var_ins}"; fErrControl ${FUNCNAME[0]} ${LINENO}
        elif [ "${var_ins}" = "nvim" ]
        then
            fSetup "${var_ins}"; fErrControl ${FUNCNAME[0]} ${LINENO}
        elif [ "${var_ins}" = "all" ]
        then
            fSetup "vim"; fErrControl ${FUNCNAME[0]} ${LINENO}

            fSetup "nvim"; fErrControl ${FUNCNAME[0]} ${LINENO}
        else
            # echo "Known instance ${var_ins}"
            # Test
            fSetup "nvim"; fErrControl ${FUNCNAME[0]} ${LINENO}
        fi
        flag_setup_config=true
    fi
    if [ ${flag_setup_config} = true ]
    then
        fSetupCusConfig; fErrControl ${FUNCNAME[0]} ${LINENO}
        fInstallScript; fErrControl ${FUNCNAME[0]} ${LINENO}
    fi

    if [ ${flag_setup_lite} = true ]
    then
        fSetup_lite; fErrControl ${FUNCNAME[0]} ${LINENO}
    fi

    if [ ${flag_plugin_check} = true ]
    then
        fPlugins_check; fErrControl ${FUNCNAME[0]} ${LINENO}
    fi
}

fMain $@
