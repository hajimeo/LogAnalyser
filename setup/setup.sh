#!/usr/bin/env bash
function usage() {
    echo "Under construction...

NOTE:
  Global variables start with _ and all capital.
  Local variables also start with _ and all small letters.
"
}

### Executable functions with -f ###############################################
function f_validatations() {
    _is_in_path "rsync" || return $?
    _is_in_path "curl" || return $?
    _is_in_path "rg" || return $?
    _is_in_path "pip" || return $?
    _is_in_path "php-fpm" || return $?

    _exist "/etc/php-fpm.conf" || return $?
    if ! _exist "/etc/php-fpm.d/www.conf" "" ; then
        if [ ! -s "/etc/php-fpm.d/www.conf.default" ] || ! cp -p /etc/php-fpm.d/www.conf.default /etc/php-fpm.d/www.conf; then
            _log "ERROR" "No /etc/php-fpm.d/www.conf"
            return 1
        fi
    fi
}

function f_start_caddy() {

}


### (supposed to be) private functions #########################################
function _is_in_path() {
    local _cmd="$1"
    local _err_msg="${2-"${_cmd} is not in PATH"}"
    if ! which ${_cmd} &>/dev/null; then
        [ -n "${_err_msg}" ] && _log "ERROR" "${_err_msg}"
        return 1
    fi
}

function _exist() {
    local _path="$1"
    local _err_msg="${2-"${_path} does not exist or empty."}"
    if [ ! -s "${_path}" ]; then
        [ -n "${_err_msg}" ] && _log "ERROR" "${_err_msg}"
        return 1
    fi
}

function _log() {
    if [ -n "${_LOG_FILE_PATH}" ]; then
        echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $@" | tee -a ${_LOG_FILE_PATH} 1>&2
    else
        echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $@" 1>&2
    fi
}


### main() ####################################################################
if [ "$0" = "$BASH_SOURCE" ]; then
    # parsing command options
    while getopts "f:h" opts; do
        case $opts in
            f)
                _FUNCTION_EVAL="$OPTARG"
                ;;
            h)
                usage | less
                exit 0
        esac
    done

    if [[ "$_FUNCTION_EVAL" =~ ^f_ ]]; then
        eval "$_FUNCTION_EVAL"
        exit $?
    fi

    # Step 1: Make sure all necessary commands are installed.
    #         As how to install is diff by OS, not installing but just error.
    f_validatations || exit $?
    f_start_caddy || exit $?
fi