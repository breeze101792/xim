#!/bin/bash
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
export PATH_LAB="${PATH_ROOT}/lab"

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
    printf "    %- 16s\t%s\n" "--profiling" "Profile vim starup"
    printf "    %- 16s\t%s\n" "--startuptime" "Record startup time by vim's --startuptime"
    printf "    %- 16s\t%s\n" "-v|--verbose" "Print in verbose mode"
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
###########################################################
## Functions
###########################################################
function fexample()
{
    fPrintHeader ${FUNCNAME[0]}

}
function flab_setup()
{
    # fPrintHeader ${FUNCNAME[0]}
    [ ! -d ${PATH_LAB} ] && mkdir -p ${PATH_LAB}
}
function fprofiling()
{
    fPrintHeader ${FUNCNAME[0]}
    flab_setup
    pushd ${PATH_LAB}

    local var_profile='profile.log'
    local var_profile_time='profile_time.log'
    # --cmd <command>      Execute <command> before loading any vimrc file
    # -c <command>         Execute <command> after loading the first file
    [ -f ${var_profile}      ] && rm ${var_profile}
    [ -f ${var_profile_time} ] && rm ${var_profile_time}

    vim --cmd "profile start ${var_profile}" \
        --cmd 'profile func *' \
        --cmd 'profile file *' \
        -c 'profdel func *' \
        -c 'profdel file *' \
        -c 'qa!'

    vim -c 'let timings=[]' \
        -c "g/^SCRIPT/call add(timings, [getline('.')[len('SCRIPT  '):], matchstr(getline(line('.')+1), '^Sourced \zs\d\+')]+map(getline(line('.')+2, line('.')+3), 'matchstr(v:val, ''\d\+\.\d\+$'')'))  " \
        -c 'enew' \
        -c "call setline('.', ['count total (s)   self (s)  script']+map(copy(timings), 'printf(\"%5u %9s   %8s  %s\", v:val[1], v:val[2], v:val[3], v:val[0])'))" \
        -c "2,$ sort" \
        -c "w ${var_profile_time}" \
        ${var_profile}

    # " Open profile.log file in vim first
    # let timings=[]
    # g/^SCRIPT/call add(timings, [getline('.')[len('SCRIPT  '):], matchstr(getline(line('.')+1), '^Sourced \zs\d\+')]+map(getline(line('.')+2, line('.')+3), 'matchstr(v:val, ''\d\+\.\d\+$'')'))
    # enew
    # call setline('.', ['count total (s)   self (s)  script']+map(copy(timings), 'printf("%5u %9s   %8s  %s", v:val[1], v:val[2], v:val[3], v:val[0])'))
    popd
}
function fstartup()
{
    fPrintHeader ${FUNCNAME[0]}
    flab_setup
    pushd ${PATH_LAB}

    local var_startup='startup.log'
    # --cmd <command>      Execute <command> before loading any vimrc file
    # -c <command>         Execute <command> after loading the first file
    [ -f ${var_startup}      ] && rm ${var_startup}

    vim --startuptime ${var_startup} \
        -c 'qa!'
    vim ${var_startup}

    popd
}
## Main Functions
###########################################################
function fMain()
{
    # fPrintHeader "Launch ${VAR_SCRIPT_NAME}"
    local var_action=''
    local flag_verbose=false

    while [[ $# != 0 ]]
    do
        case $1 in
            # Options
            --profiling|pf)
                var_action='profiling'
                fprofiling
                exit 0
                ;;
            --starttime|st)
                var_action='startuptime'
                fstartup
                exit 0
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
}

fMain $@
