#!/bin/bash
###########################################################
## DEF
###########################################################
export DEF_COLOR_RED='\033[0;31m'
export DEF_COLOR_YELLOW='\033[0;33m'
export DEF_COLOR_GREEN='\033[0;32m'
export DEF_COLOR_NORMAL='\033[0m'

export DEF_PROJ_FOLDER='.vimproject'
###########################################################
## Vars
###########################################################
export VAR_SCRIPT_NAME="$(basename ${BASH_SOURCE[0]%=.})"
export VAR_VIM_INSTANCE="nvim"

###########################################################
## Options
###########################################################
export OPTION_VERBOSE=false

###########################################################
## Path
###########################################################
export PATH_ROOT="$(realpath $(dirname ${BASH_SOURCE[0]}))"

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
    printf "    %s\n" "run test: xim.sh -a"
    echo "[Options]"
    printf "    %- 32s\t%s\n" "init" "Tag init commands"
    printf "    %- 32s\t%s\n" "update" "Tag update commands"
    printf "    %- 32s\t%s\n" "vim|nvim|edit|*" "Editor commands, default action"
    # printf "    %- 32s\t%s\n" "-v|--verbose" "Print in verbose mode"
    printf "    %- 32s\t%s\n" "help" "Print helping"
    # echo "[Commands]"
    # fInit -h
    # fUpdate -h
    # fEdit -h
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
fFileRoot()
{
    local tmp_path=$(realpath .)
    local grep_args=""
    local target="$@"
    local target_path=${tmp_path}
    local flag_verbose="n"

    # while ! ls -a "${tmp_path}" | grep -q ${grep_args} ${target};
    # Full match, only test if the file exist or not.
    while ! test -e "${tmp_path}/${target}";
    do
        tmp_path="${tmp_path}/.."
        pushd "${tmp_path}" > /dev/null
        tmp_path="$(pwd)"
        [ "${flag_verbose}" = "y" ] && echo "Searching in ${tmp_path}"
        if [ "$(pwd)" = "/" ];
        then
            [ "${flag_verbose}" = "y" ] && echo 'Hit the root'
            popd > /dev/null
            return 1
        fi
        popd > /dev/null
        target_path=${tmp_path}
    done

    if test -e "${target_path}"
    then
        cd "${target_path}"
        return 0
    else
        return 1
    fi
}
###########################################################
## Functions
###########################################################
function fexample()
{
    fPrintHeader ${FUNCNAME[0]}

}
function fEnvSantiyCheck()
{
    local var_current_path=$(pwd)
    # if env |grep VIDE
    # then
    #     echo "Containation ENV found."
    # fi

    if ! command -v "nvim" > /dev/null 2>&1
    then
        export VAR_VIM_INSTANCE="vim"
    fi
    
    # FIXME, remove me, it's just a patch
    local legacy_proj_name="vimproj"
    if fFileRoot ${legacy_proj_name}
    then
        DEF_PROJ_FOLDER=${legacy_proj_name}
    fi
    cd ${var_current_path}
}

function fUpdate()
{
    local cpath=${PWD}
    local var_proj_folder="${DEF_PROJ_FOLDER}"
    local var_list_file="proj.files"

    local var_tags_file="tags"
    local var_cscope_file="cscope.db"
    local var_cctree_file="cctree.db"
    local var_tmp_folder="tmp_db_$(date +%Y%m%d_%H%M%S)"
    local flag_error_happen='y'

    local flag_system_include='n'

    while [[ "$#" != 0 ]]
    do
        case $1 in
            -si|--system-include)
                flag_system_include='y'
                ;;
            -v|--verbose)
                flag_verbose="y"
                shift 1
                ;;
            -h|--help)
                printf "%s %s\n" "pvupdate" -cd "pvupdate function"
                printf "%s %s\n" "SYNOPSIS"
                printf "    %s %s\n" "pvupdate [Options] [Value]"
                printf "%s %s\n" "Options"
                printf "    %- 32s %s\n" "-si|--system-include" "Add linux system include "
                printf "    %- 32s %s\n" "-h|--help" "Print help function "
                return 0
                ;;
            *)
                echo "Wrong args, $@"
                return -1
                ;;
        esac
        shift 1
    done
    var_cscope_cmd+=("-U")

    if [ "${flag_system_include}" = "n" ]
    then
        var_cscope_cmd+=("-k")
    fi

    fFileRoot ${var_proj_folder}

    if test -f "${var_proj_folder}/${var_list_file}"
    then
        cd ${var_proj_folder}
        var_list_file=$(realpath "${var_list_file}")

        echo "Found ${var_list_file} in $(pwd)"
    else
        echo "${var_list_file} not found."
        return 1
    fi

    # [ -f ${var_cscope_file} ] && rm ${var_cscope_file} 2> /dev/null
    # [ -f ${var_cctree_file} ] && rm ${var_cctree_file} 2> /dev/null
    # [ -f ${var_tags_file} ] && rm ${var_tags_file} 2> /dev/null
    [ -d ${var_tmp_folder} ] && rm -rf ${var_tmp_folder} 2> /dev/null

    mkdir -p ${var_tmp_folder}
    pushd ${var_tmp_folder}
    ########################################
    # Add c(uncompress) for fast read

    ## Ctags
    # ctags -L proj.files
    $(ctags -R --c++-kinds=+p --C-kinds=+p --fields=+iaS --extra=+q -L ${var_list_file} || echo 'catg run fail' && flag_error_happen='n' )&
    # ctags -R  --C-kinds=+p --fields=+aS --extra=+q
    # ctags -R -f ~/.vim/${var_tags_file}/c  --C-kinds=+p --fields=+aS --extra=+q

    ## Cscope
    # cscope -c -b -i ${var_list_file} -f ${var_cscope_file} || echo 'cscope run fail' && flag_error_happen='n'
    cscope -c -b -R -q ${var_cscope_cmd[@]} -i ${var_list_file} -f ${var_cscope_file} || echo 'cscope run fail' && flag_error_happen='n'

    wait
    # command -V ccglue && ccglue -S cscope.out -o ${var_cctree_file}
    command -V ccglue > /dev/null 2>&1 && ccglue -S ${var_cscope_file} -o ${var_cctree_file} || echo "Command ccglue not found."
    # mv cscope.out ${var_cscope_file}
    ########################################
    popd
    if [ "${flag_error_happen}" = "n" ]
    then
        cp -rf ${var_tmp_folder}/${var_tags_file} .
        cp -rf ${var_tmp_folder}/*.db .
        cp -rf ${var_tmp_folder}/${var_cscope_file}* .
        printf "${DEF_COLOR_GREEN}Tag generate successfully.${DEF_COLOR_NORMAL}\n"
    else
        ls ${var_tmp_folder}
        printf "${DEF_COLOR_RED}Fail to generate tag${DEF_COLOR_NORMAL}\n"
        test -f ${var_tags_file} || echo 'Update ctags' && cp -f ${var_tmp_folder}/${var_tags_file} ${var_tmp_folder}
        test -f ${var_cscope_file} || echo 'Update cscope' && cp -f ${var_tmp_folder}/${var_cscope_file}* ${var_tmp_folder}
        test -f ${var_cctree_file} || echo 'Update cctree' && cp -f ${var_tmp_folder}/${var_cctree_file} ${var_tmp_folder}
    fi

    rm -rf ${var_tmp_folder} 2> /dev/null

    cd ${cpath}
}
function fInit()
{
    local var_cpath=$(pwd)
    local var_proj_path="."
    local var_proj_folder="${DEF_PROJ_FOLDER}"
    local var_list_file="proj.files"
    local var_list_header_file="proj_header.files"

    local var_tags_file="tags"
    local var_cscope_file="cscope.db"
    local var_cctree_file="cctree.db"
    local var_config_file="proj.vim"

    local header_rule=()
    local src_path=()
    local file_ext=()
    local file_exclude=()
    local path_exclude=()
    local find_cmd=""
    local flag_append=n
    local flag_header=n

    # path_exclude+=("-not -path '*/.repo/*'")
    # ignore all hiden files
    path_exclude+=("-not -path '*/.*'")

    file_exclude+=("-iname '*.pyc'")

    file_ext+=("-iname '*.c'")
    file_ext+=("-o -iname '*.cc'")
    file_ext+=("-o -iname '*.c++'")
    file_ext+=("-o -iname '*.cxx'")
    file_ext+=("-o -iname '*.cpp'")

    file_ext+=("-o -iname '*.h'")
    file_ext+=("-o -iname '*.hh'")
    file_ext+=("-o -iname '*.h++'")
    file_ext+=("-o -iname '*.hxx'")
    file_ext+=("-o -iname '*.hpp'")
    file_ext+=("-o -iname '*.iig'")

    file_ext+=("-o -iname '*.java'")

    header_rule+=("-iname 'include'")
    header_rule+=("-o -iname 'inc'")

    while [[ "$#" != 0 ]]
    do
        case $1 in
            -a|--append)
                flag_append="y"
                ;;
            -e|--extension)
                file_ext+=("-o -iname \"*.${2}\"")
                shift 1
                ;;
            -x|--exclude)
                file_exclude+=("-o -iname \"${2}\"")
                shift 1
                ;;
            -l|--linux)
                src_path+=("/lib/modules/$(uname -r)/source")
                shift 1
                ;;
            -xp|--exclude-path)
                path_exclude+=("-not -path \"*/${2}/*\"")
                shift 1
                ;;
            -c|--clean)
                local tmp_file_array=("${var_list_file}" "${var_tags_file}" "${var_cscope_file}" "${var_cctree_file}" "pvinit.err" )
                for each_file in "${tmp_file_array[@]}"
                do
                    if [ -f "${each_file}" ]
                    then
                        echo "remove ${each_file}"
                        rm ${each_file}
                    fi
                done
                test -d ${var_proj_folder} && rm -rf ${var_proj_folder}

                # return 0
                ;;
            -H|--header)
                flag_header=y
                ;;
            -h|--help)
                printf "%s %s\n" "pvinit"
                printf "%s %s\n" "SYNOPSIS"
                printf "    %s %s\n" "pvinit [Options] [Dirs]"
                printf "%s %s\n" "Options"
                printf "    %- 32s %s\n" "-a|--append" "append more fire in file list"
                printf "    %- 32s %s\n" "-e|--extension" "add file extension on search"
                printf "    %- 32s %s\n" "-x|--exclude" "exclude file on search"
                printf "    %- 32s %s\n" "-xp|--exclude-path" "exclude file path on search"
                printf "    %- 32s %s\n" "-l|--linux" "include linux header"
                printf "    %- 32s %s\n" "-c|--clean" "Clean related files"
                printf "    %- 32s %s\n" "-H|--header" "Add header vim code"
                printf "    %- 32s %s\n" "-h|--help" "Print help function "
                return 0
                ;;
            *)
                src_path+=($@)
                break
                ;;
        esac
        shift 1
    done
    # prechecking
    if test -z ${src_path}
    then
        echo "Please enter folder name"
        return -1
    fi

    # path checking
    if ! fFileRoot ${var_proj_folder}
    then
        fFileRoot ".repo" || fFileRoot ".git"
        mkdir -p ${var_proj_folder}
    fi

    var_proj_path="$(realpath .)"
    var_proj_folder="${var_proj_path}/${var_proj_folder}"
    var_list_file="${var_proj_folder}/${var_list_file}"
    var_config_file="${var_proj_folder}/${var_config_file}"
    var_list_header_file="${var_proj_folder}/${var_list_header_file}"

    # file cleaning
    if [ "${flag_append}" = "n" ]
    then
        if [ -f "${var_list_file}" ]
        then
            rm "${var_list_file}" 2> /dev/null
        fi
    fi

    echo "################################################################"
    echo "Searching Path    : ${#src_path[@]}:${src_path[@]}"
    echo "file_ext          : ${file_ext[@]}"
    echo "Project List File : ${var_list_file}"
    echo "Project file path : ${var_proj_path}"
    echo "################################################################"

    cd ${var_cpath}
    for each_path in ${src_path[@]}
    do
        # echo "Searching path: ${each_path}"
        if [ ! -e ${each_path} ]
        then
            printf "${DEF_COLOR_RED}folder not found: ${DEF_COLOR_NORMAL}"
            echo -e "${each_path}"
            continue
        else
            local tmp_path=$(realpath "${each_path}")

            ## Searcing srouce file
            printf "${DEF_COLOR_GREEN}Searching folder: ${DEF_COLOR_NORMAL}"
            echo -e "$tmp_path"
            find_cmd="find ${tmp_path} \( -type f ${file_ext[@]} \) -not \( ${file_exclude[@]} \) ${path_exclude[@]} | xargs realpath -q >> \"${var_list_file}\""
            echo ${find_cmd}
            eval "${find_cmd}"

            ## Search inlcude
            if [ "${flag_header}" = "y" ]
            then
                find_cmd="find ${tmp_path} \( -type d ${header_rule[@]} \) ${path_exclude[@]} | xargs realpath -q >> \"${var_list_header_file}\""
                echo ${find_cmd}
                eval "${find_cmd}"
            fi
        fi
    done

    ## Remove duplication
    local tmp_file="${var_proj_folder}/tmp.files"
    # resort file list
    cat "${var_list_file}" | sort | uniq > "${tmp_file}"
    mv "${tmp_file}" "${var_list_file}"

    # update vim script file
    if [ "${flag_header}" = "y" ] && test -f ${var_list_header_file}
    then
        cat "${var_list_header_file}" | sort | uniq > "${tmp_file}"
        mv "${tmp_file}" "${var_list_header_file}"

        cat ${var_list_header_file} | sed "s/^/set path+=/g" > ${var_config_file}
    fi

    test -f "${var_config_file}" || touch ${var_config_file}

    fUpdate
    cd ${var_cpath}
    echo Vim project create on ${var_proj_path}
}

function fEdit()
{
    # if [ -d $1 ]
    # then
    #     echo "Please enter a file name"
    # fi
    local vim_args=( "" )
    local cpath=`pwd`
    local cmd_args=()
    local flag_cctree=n
    local flag_proj_vim=y
    local flag_time=n
    local var_timestamp="$(date +%Y%m%d_%H%M%S)"

    local var_proj_folder="${DEF_PROJ_FOLDER}"
    local var_list_file="proj.files"

    local var_tags_file="tags"
    local var_cscope_file="cscope.db"
    local var_cctree_file="cctree.db"
    local var_config_file="proj.vim"

    local var_vim_distro="${VAR_VIM_INSTANCE}"

    while [[ "$#" != 0 ]]
    do
        case $1 in
            -p|--pure-mode)
                cmd_args+=("-u NONE")
                ;;
            -s|--session)
                if [[ "$#" > 1 ]]
                then
                    tmp_var=$2
                    if [ "${tmp_var}" = "def" ] || [ "${tmp_var}" = "default" ] ||
                        [ "${tmp_var}" = "as" ] || [ "${tmp_var}" = "autosave" ]
                    then
                         export VIDE_SH_SESSION_RESTORE=$2
                        shift 1
                    else
                         export VIDE_SH_SESSION_RESTORE='autosave'
                    fi
                else
                     export VIDE_SH_SESSION_RESTORE='autosave'
                fi
                ;;
            -e|--extra-command)
                cmd_args+=("$2")
                shift 1
                ;;
            -m|--map)
                flag_cctree=y
                ;;
            # -l|--lite)
            #     cmd_args+=("-u $HS_PATH_IDE/tools/vimlite.vim")
            #     ;;
            -c|--clip)
                shift 1
                local buf_tmp="$@"
                [ -f "${buf_tmp}" ] && buf_tmp=$(realpath ${buf_tmp})
                [ -f "${HOME}/.vim/clip" ] && rm -f ${HOME}/.vim/clip

                # printf "V\n%s" "${buf_tmp}" | sed '$ s/$.*//g' > ${HOME}/.vim/clip
                printf "V\n%s\n" "${buf_tmp}" > ${HOME}/.vim/clip
                return 0
                ;;
            -t|--time)
                flag_time=y
                cmd_args+=("-X --startuptime startup_${var_timestamp}.log")
                hsexc hs_varconfig -s "${HS_VAR_LOGFILE}" "startup_${var_timestamp}.log"
                ;;
            --buffer-file|buffer|buf)
                # This is work with HS
                vim_args+="$(hsexc hs_varconfig -g ${HS_VAR_LOGFILE})"
                ;;
            # ENV
            p|plugin)
                if [[ "$#" > 1 ]]
                then
                    tmp_var=$2
                    if [ "${tmp_var}" = "y" ] || [ "${tmp_var}" = "n" ]
                    then
                        export VIDE_SH_PLUGIN_ENABLE=$2
                    else
                        export VIDE_SH_PLUGIN_ENABLE='y'
                    fi
                else
                    echo 'fail to read args. $@'
                    return -1
                fi
                shift 1
                ;;
            sc|schars)
                if [[ "$#" > 1 ]]
                then
                    tmp_var=$2
                    if [ "${tmp_var}" = "y" ] || [ "${tmp_var}" = "n" ]
                    then
                        export VIDE_SH_SPECIAL_CHARS=$2
                    else
                        export VIDE_SH_SPECIAL_CHARS='y'
                    fi
                else
                    echo 'fail to read args. $@'
                    return -1
                fi
                shift 1
                ;;
            -i|--instance)
                var_vim_distro="${2}"
                shift 1
                ;;
            -d|--debug)
                cmd_args+=("-Vvim_msg.log")
                ;;
            -h|--help)
                printf "%s %s\n" "pvim"
                printf "      %s %s\n" "pvim [Options] [File]"
                printf "%s %s\n" "SYNOPSIS"
                printf "      %s %s\n" "pvim [Options] [File]"
                printf "%s %s\n" "Options"
                printf "    %- 32s %s\n" "-m|--map"  "Load cctree in vim"
                printf "    %- 32s %s\n" "-s|--session"  "Restore session"
                printf "    %- 32s %s\n" "-i|-intance"  "select vim runtint, default use ${VAR_VIM_INSTANCE}."
                printf "    %- 32s %s\n" "-p|--pure-mode"  "Load withouth ide file"
                printf "    %- 32s %s\n" "--buffer-file|buffer|buf"  "Open file with hs var(${HS_VAR_LOGFILE})"
                printf "    %- 32s %s\n" "-t|--time"  "Enable startup debug mode"
                printf "    %- 32s %s\n" "-c|--clip"  "Save file in vim buffer file"
                printf "    %- 32s %s\n" "-e|--extra-command"  "pass extra command to vim"
                printf "    %- 32s %s\n" "-v|--verbose"  "Record runtime log.(./vim_msg.log)"
                printf "    %- 32s %s\n" "-h|--help"  "Print help function "
                printf "%s %s\n" "Options"
                printf "    %- 32s %s\n" "p|plugin"  "Plugin disable/enable, plugin y/n"
                printf "    %- 32s %s\n" "sc|schars"  "Special chars disable/enable, schars y/n"
                printf "%- 32s %s\n" "vim-Options"
                printf "    %- 32s %s\n" "-R"  "vim read only mode"
                return 0
                ;;
            *)
                if test -f "$*"
                then
                    vim_args+="'$@'"
                else
                    vim_args+="$@"
                fi
                ;;
        esac
        shift 1
    done

    # unset var
    # fCleanEnv

    if fFileRoot ${var_proj_folder}
    then
        var_proj_folder="$(realpath ${var_proj_folder})"
    else
        var_proj_folder="$(realpath .)"
    fi

    cd "${var_proj_folder}"

    if test -f "./proj.vim"
    then
        export VIDE_SH_PROJ_DATA_PATH=$(realpath ${var_proj_folder})
    fi

    # NOTE. currently this will be set with VIDE_SH_PROJ_DATA_PATH
    if false
    then
        if test -f "${var_tags_file}"
        then
            export VIDE_SH_TAGS_DB=$(realpath ${var_tags_file})
            # printf "Project %- 6s: %s\n" "Ctag" "${VIDE_SH_TAGS_DB}"
            # else
            #     printf "Project %- 6s: %s\n" "Ctag" "not found"
        fi

        if test -f "${var_cscope_file}"
        then
            export VIDE_SH_CSCOPE_DB=$(realpath ${var_cscope_file})
            # printf "Project %- 6s: %s\n" "CScope" "${VIDE_SH_CSCOPE_DB}"
            # else
            #     printf "Project %- 6s: %s\n" "CScope" "not found"
        fi

        if [ "${flag_cctree}" = "y" ] && test -f "${var_cctree_file}"
        then
            echo "Don't forget to use cctreeupdate"
            export VIDE_SH_CCTREE_DB=$(realpath ${var_cctree_file})
            # printf "Project %- 6s: %s\n" "CCTree" "${VIDE_SH_CCTREE_DB}"
        fi
    fi

    if [ "${flag_proj_vim}" = "y" ] && test -f "${var_config_file}"
    then
        export VIDE_SH_PROJ_SCRIPT=$(realpath ${var_config_file})
        # printf "Project %- 6s: %s\n" "Script" "${VIDE_SH_PROJ_SCRIPT}"
    fi

    cd "${cpath}"
    eval ${var_vim_distro} ${cmd_args[@]} ${vim_args[@]}
    printf "Launching %s: ${DEF_COLOR_GREEN}%s${DEF_COLOR_NORMAL}\n" "${VIDE_SH_PROJ_DATA_PATH}" "${var_vim_distro} ${cmd_args[@]} ${vim_args[@]}"

    if [ "${flag_time}" = "y" ]
    then
        grep "STARTED" startup_${var_timestamp}.log
    fi
}
## Main Functions
###########################################################
function fMain()
{
    # fPrintHeader "Launch ${VAR_SCRIPT_NAME}"
    local flag_verbose=false
    local flag_init=false
    local flag_update=false
    local flag_edit=false

    if [[ $# == 0 ]]
    then
        flag_edit=true
    fi

    while [[ $# != 0 ]]
    do
        case $1 in

            init)
                shift 1
                flag_init=true
                break
                ;;
            update)
                shift 1
                flag_update=true
                ;;
            vim|nvim|edit)
                shift 1
                flag_edit=true
                break
                ;;
            # Options
            -v|--verbose)
                flag_verbose=true
                ;;
            # -h|--help)
            help)
                fHelp
                exit 0
                ;;
            *)
                flag_edit=true
                break
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

    fEnvSantiyCheck

    if [ ${flag_init} = true ]
    then
        fInit "$@"; fErrControl ${FUNCNAME[0]} ${LINENO}
    elif [ ${flag_update} = true ]
    then
        fUpdate "$@"; fErrControl ${FUNCNAME[0]} ${LINENO}
    else
    # elif [ ${flag_edit} = true ]
    # then
        fEdit "$@"; fErrControl ${FUNCNAME[0]} ${LINENO}
    fi
}

fMain "$@"
