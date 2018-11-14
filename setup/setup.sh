#!/usr/bin/env bash
function usage() {
    echo "Setup and start web server
USAGE:
    $BASH_SOURCE
or
    $BASH_SOURCE -f <f_some_function>

NOTE:
  Global variables start with _ and all capital.
  Local variables also start with _ and all small letters.
"
}


### Global variables ###########################################################
_ROOT_DIR="$(dirname "$(dirname "$BASH_SOURCE")")"
_HOST="0.0.0.0"
_PORT="48080"


### Executable functions with -f ###############################################
function f_validations() {
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

function f_web_start() {
    local _root_dir="${1:-${_ROOT_DIR}}"
    if [ ! -d "${_root_dir%/}/log" ]; then
        if ! mkdir -p -m 777 ${_root_dir%/}/log; then
            _log "ERROR" "Couldn't create ${_root_dir%/}/log"
            return 1
        fi
    fi

    if [ ! -s "${_root_dir%/}/conf/Caddyfile" ]; then
        _generate_config || return $?
    fi
    nohup ${_root_dir%/}/bin/caddy-`uname` -conf ${_root_dir%/}/conf/Caddyfile -root ${_root_dir%/}/web/public 1>${_root_dir%/}/log/caddy.out 2>${_root_dir%/}/log/caddy.err &
    echo "$!" > ${_root_dir%/}/log/caddy.pid
    _log "INFO" "Started web server (`cat ${_root_dir%/}/log/caddy.pid`)"
}

function f_web_stop() {
    local _root_dir="${1:-${_ROOT_DIR}}"
    # TODO: should check if it's really caddy
    kill `cat ${_root_dir%/}/log/caddy.pid`
}


### (supposed to be) private functions #########################################
function _generate_config() {
    local _host="${1:-${_HOST}}"
    local _port="${2:-${_PORT}}"
    local _root_dir="${3:-${_ROOT_DIR}}"

    if [ ! -d "${_root_dir%/}/conf" ]; then
        if ! mkdir -p ${_root_dir%/}/conf; then
            _log "ERROR" "Couldn't create ${_root_dir%/}/conf"
            return 1
        fi
    fi

    # At this moment, error is also stdout
    echo ${_host}':'${_port}'
gzip
log stdout
errors stdout
fastcgi / 127.0.0.1:9000 php' > ${_root_dir%/}/conf/Caddyfile
#forwardproxy { acl { allow all } }
}

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
    f_validations || exit $?
    f_web_start || exit $?
fi