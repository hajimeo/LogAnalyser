#!/usr/bin/env bash
type _import &>/dev/null || _import() { [ -s /tmp/${1} ] || curl -sf --compressed "https://raw.githubusercontent.com/hajimeo/samples/master/bash/$1" -o /tmp/${1}; . /tmp/${1}; }

_import "utils.sh"


usage() {
    echo "Client script to upload a zip file (or files in a directory)
USAGE:
    $BASH_SOURCE -s server_url [-p password] [-n name] [-i ipynb_script_name] [-f path/to/support.zip]

-s server_url
    (http|https)://LogAnalyser_Hostname:Port/

-p password
    Login password.

-n name
    Name of this scan. A sub-directory will be created by this name

-i ipynb_script_name
    To specify the name of ipynb script

-f path/to/support.zip
    A path to a support zip, which will be uploaded into the Log Analyser.

REQUIREMENTS
    curl, python
"
}


: ${_COOKIE:="/tmp/la_cookie.txt"}
alias _curl="curl -sfL -D/dev/stderr -b ${_COOKIE} -c ${_COOKIE}"
alias b64encode='python -c "import sys, base64; print(base64.b64encode(sys.stdin.read().encode(\"utf-8\")).decode())"'
_XSRF=""


function _login() {
    local _pwd="${1:-"admin123"}"
    local _jupyter_url="${2:-"${_JUPYTER_URL}"}"

    [ -z "${_jupyter_url}" ] && return 11
    _curl -o/dev/null "${_jupyter_url%/}/login"
    _XSRF="$(grep -w '_xsrf' ${_COOKIE} | awk '{print $7}')"
    [ -z "${_XSRF}" ] && return 12
    _curl -o/dev/null "${_jupyter_url%/}/login?next=%2F" \
        --data-urlencode "_xsrf=${_XSRF}" \
        --data-urlencode "password=${_pwd}"
    echo "${_XSRF}"
}

function _logout() {
    rm -f "${_COOKIE}"
}

function _get_nb() {
    local _path="${1}"  # usually name (-n)
    local _jupyter_url="${2:-"${_JUPYTER_URL}"}"

    [ -z "${_jupyter_url}" ] && return 11
    if [ -z "${_XSRF}" ]; then
        _XSRF="$(_login "${_JUPYTER_PWD}" "${_jupyter_url}")" || return $?
    fi
    if _curl "${_jupyter_url%/}/api/contents/${_path}" -X GET -H "Content-Type: application/json" > /tmp/${FUNCNAME}.tmp; then
        if [[ "${_path}" =~ \.ipynb$ ]]; then
            python -c "import json
nb=json.load(open('/tmp/${FUNCNAME}.tmp', 'r'))
codes = [c['source'] for c in nb['content']['cells'] if c['cell_type'] == 'code']
print(json.dumps(codes, indent=2))" || return $?
        else
            cat /tmp/${FUNCNAME}.tmp | python -m json.tool
        fi
    else
        cat /tmp/${FUNCNAME}.tmp
    fi
}

function _upload() {
    local _src="${1}"
    local _path="${2}"
    local _jupyter_url="${3:-"${_JUPYTER_URL}"}"

    [ -z "${_jupyter_url}" ] && return 11
    [ ! -s "${_src}" ] && return 12
    local _filename="$(basename "${_src}")"
    [ -z "${_path%/}" ] && _path="${_filename}"
    # TODO: if [ -d "${_src}" ]; then find ${_src%/} -type f ...; fi
    local _b64str="$(cat "${_src}" | b64encode)"
    cat << EOF > /tmp/${FUNCNAME}.json
{
    "content": "${_b64str}",
    "name": "${_filename}",
    "path": "${_path%/}",
    "format": "base64",
    "type": "file"
}
EOF
    if [ -z "${_XSRF}" ]; then
        _XSRF="$(_login "${_JUPYTER_PWD}" "${_jupyter_url}")" || return $?
    fi
    if _curl "${_jupyter_url%/}/api/contents/${_path}?_xsrf=${_XSRF}" -X PUT -H "Content-Type: application/json" \
        --data @/tmp/${FUNCNAME}.json > /tmp/${FUNCNAME}.tmp; then
        cat /tmp/${FUNCNAME}.tmp | python -m json.tool
    else
        cat /tmp/${FUNCNAME}.tmp
    fi
}

function _kernels() {
    local _id="${1}"
    local _jupyter_url="${2:-"${_JUPYTER_URL}"}"

    [ -z "${_jupyter_url}" ] && return 11
    if [ -z "${_XSRF}" ]; then
        _XSRF="$(_login "${_JUPYTER_PWD}" "${_jupyter_url}")" || return $?
    fi
    if _curl "${_jupyter_url%/}/api/kernels/${_id}?_xsrf=${_XSRF}" -X GET -H "Content-Type: application/json" > /tmp/${FUNCNAME}.tmp; then
        cat /tmp/${FUNCNAME}.tmp | python -m json.tool
    else
        cat /tmp/${FUNCNAME}.tmp
    fi
}

function _terminals() {
    local _id="${1}"
    local _jupyter_url="${2:-"${_JUPYTER_URL}"}"

    [ -z "${_jupyter_url}" ] && return 11
    if [ -z "${_XSRF}" ]; then
        _XSRF="$(_login "${_JUPYTER_PWD}" "${_jupyter_url}")" || return $?
    fi
    if _curl "${_jupyter_url%/}/api/terminals/${_id}?_xsrf=${_XSRF}" -X GET -H "Content-Type: application/json" > /tmp/${FUNCNAME}.tmp; then
        cat /tmp/${FUNCNAME}.tmp | python -m json.tool
    else
        cat /tmp/${FUNCNAME}.tmp
    fi
}



### main() #####################################################################
main() {
    _login "${_JUPYTER_PWD}" || return $?
    _upload "${_FILE}" "${_NAME}" || return $?
    # TODO: execute log analyse starting python code
}

if [ "$0" = "$BASH_SOURCE" ]; then
    _JUPYTER_URL=""
    _JUPYTER_PWD=""
    _NAME=""
    _IPYNB_NAME=""
    _FILE=""
    # parsing command options
    while getopts "s:p:n:i:f:h" opts; do
        case $opts in
            s)
                _JUPYTER_URL="$OPTARG"
                ;;
            p)
                _JUPYTER_PWD="$OPTARG"
                ;;
            n)
                _NAME="$OPTARG"
                ;;
            i)
                _IPYNB_NAME="$OPTARG"
                ;;
            f)
                _FILE="$OPTARG"
                ;;
            h)
                usage | less
                exit 0
        esac
    done

    main
fi