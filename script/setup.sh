#!/usr/bin/env bash
type _import &>/dev/null || _import() { [ -s /tmp/${1} ] || curl -sf --compressed "https://raw.githubusercontent.com/hajimeo/samples/master/bash/$1" -o /tmp/${1}; . /tmp/${1}; }   # not using _$$

_import "utils.sh"
_import "_setup_host.sh"    # functions for Ubuntu OS
_import "setup_work_env.sh" # functions for setting up tools and applicaitons (python, golang, java ...)


usage() {
    echo "Setup and start service for Log analysis
USAGE:
    $BASH_SOURCE
or
    $BASH_SOURCE -f <f_some_function> [-a <function arguments>]

NOTE:
  Global variables start with _ and all capital letters.
  Local variables also start with _ and all small letters.
"
}


### Global variables for this script ##########################################
: ${_APP_USER:="loganalyser"}
: ${_APP_DIR:="/var/tmp/share/${_APP_USER%/}"}
: ${_NXRM_APT_PROXY:=""}
: ${_NXRM_PYPI_PROXY:=""}


### Executable functions (start with f_) #######################################
function f_setup_service() {
    local __doc__="Setup jupyter as service on Ubuntu"
    local _user="${1:-"${_APP_USER}"}"
    local _dir="${2:-"${_APP_DIR}"}"

    if [ ! -d "${_dir}" ]; then
        sudo -u "${_user}" mkdir -v -m 777 -p "${_dir}" #|| return $?
    fi
    chown -v ${_user}: "${_dir}"

    local _svc_file="/etc/systemd/system/jupyter.service"
    local _env=""
    local _bin=""
    if [ -d "/home/${_user}/.pyvenv/bin" ]; then
        _env="Environment=\"PATH=/home/${_user}/.pyvenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\""
        _bin="/home/${_user}/.pyvenv/bin/"  # end with "/"
    fi
    if [ -d "/home/${_user}/IdeaProjects/samples/python" ]; then
        _env="${_env}
Environment=\"PYTHONPATH=/home/${_user}/IdeaProjects/samples/python\""
    fi
    cat << EOF > "${_svc_file}"
[Unit]
Description=Jupyter Notebook Server

[Service]
Environment="SHELL=$(which bash)"
${_env}
Type=simple
PIDFile=/run/jupyter.pid
ExecStart=${_bin}jupyter-lab --no-browser --ip=0.0.0.0 --port=8999 --notebook-dir=${_dir}
User=${_user}
#WorkingDirectory=${_dir}
Restart=always
RestartSec=10
#KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
    chmod a+x ${_svc_file}
    systemctl daemon-reload
    systemctl enable jupyter.service
    systemctl start jupyter.service
    systemctl status jupyter.service
}

function f_apt_proxy() {
    local _url="${1:-"${_NXRM_APT_PROXY}"}"
    local _src_url="${2:-"http://archive.ubuntu.com/ubuntu/"}"
    if [ -s /etc/apt/sources.list ] && _isUrl "${_url}" "Y"; then
        sed -i.bak "s@${_src_url%/}/@${_url%/}/@g" /etc/apt/sources.list || return $?
        apt-get update || return $?
    fi
}

function f_prepare_contents() {
    local __doc__="TODO: Download necessary files sush as notebook files into _APP_DIR"
}

### (supposed to be) private functions (start with _) ##########################


### main() #####################################################################
main() {
    f_apt_proxy "${_NXRM_APT_PROXY}" || return $?

    # Install necessary commands for Ubuntu as root (or sudo)
    f_prepare || return $?

    # Create non root user for the application
    f_useradd "${_APP_USER}" || return $?

    # As this is python based application, setup python packages for the app user
    if [ -n "${_NXRM_PYPI_PROXY}" ]; then
        sudo -u "${_APP_USER}" -i bash $BASH_SOURCE -f f_setup_python -a "${_NXRM_PYPI_PROXY}"
    else
        sudo -u "${_APP_USER}" -i bash $BASH_SOURCE -f f_setup_python
    fi || return $?

    # Setup as the service (but if container is not started with init, won't work)
    if ! f_setup_service; then
        _log "WARN" "f_setup_service failed, but maybe OK if this is used in docker build."
    fi
}

if [ "$0" = "$BASH_SOURCE" ]; then
    _FUNCTION_EVAL=""
    _FUNCTION_ARGS=""
    # parsing command options
    while getopts "f:a:h" opts; do
        case $opts in
            f)
                _FUNCTION_EVAL="$OPTARG"
                ;;
            a)
                _FUNCTION_ARGS="$OPTARG"
                ;;
            h)
                usage | less
                exit 0
        esac
    done

    # if -f is specified, execute that functiona and exit
    if [[ "$_FUNCTION_EVAL" =~ ^f_ ]]; then
        eval "$_FUNCTION_EVAL ${_FUNCTION_ARGS}"
        exit $?
    fi

    main
fi
