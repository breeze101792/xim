#!/bin/bash
###########################################################
## Vars
###########################################################
export VAR_SCRIPT_NAME="$(basename ${BASH_SOURCE[0]%=.})"
export SCRIPT_ROOT="$(realpath $(dirname ${BASH_SOURCE[0]}))"
export PATH_ROOT="$(pwd)"

###########################################################
## Functions
###########################################################
fHelp()
{
    echo "${VAR_SCRIPT_NAME}"
    echo "[Example]"
    printf "    %s\n" "run help: ${VAR_SCRIPT_NAME} -h"
    echo "[Options]"
    printf "    %- 16s\t%s\n" "-v|--verbose" "Print in verbose mode"
    printf "    %- 16s\t%s\n" "-h|--help" "Print helping"
}
## Main Functions
###########################################################
function fMain()
{
    local flag_setup_mode="link"
    local flag_force="false"
    local var_template_file="${SCRIPT_ROOT}/clangd.yaml"

    if [[ "$(uname)" == "Darwin" ]]; then
        var_target_file="${HOME}/Library/Preferences/clangd/config.yaml"
    else
        var_target_file="${HOME}/.config/clangd/config.yaml"
    fi

    while [[ $# != 0 ]]
    do
        case $1 in
            -f|--force)
                flag_force="true"
                ;;
            --link)
                flag_setup_mode="link"
                ;;
            --copy)
                flag_setup_mode="copy"
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

    if ! test -f "${var_template_file}"; then
        echo "Template file not found. ${var_template_file}"
        return -1
    fi

    if test -f "${var_target_file}"; then
        if [ ${flag_force} = false ]
        then
            echo "Target file exist, ignore."
            return -1
        else
            rm "${var_target_file}"
        fi
    fi

    local tmp_parent_dir=$(dirname ${var_target_file})
    if ! test -d "${tmp_parent_dir}"; then
        echo "Folder not found, create it. ${tmp_parent_dir}"
        mkdir -p "${tmp_parent_dir}"
    fi

    if [ "${flag_setup_mode}" = "link" ]
    then
        echo ln -s "${var_template_file}" "${var_target_file}"
        ln -s "${var_template_file}" "${var_target_file}"
    else
        echo cp "${var_template_file}" "${var_target_file}"
        cp "${var_template_file}" "${var_target_file}"
    fi
    if test -f "${var_target_file}"; then
        echo "Clangd.yaml copy successfully."
    fi
}

fMain "$@"
