#!/usr/bin/env bash
type _import &>/dev/null || _import() { [ -s /tmp/${1} ] || curl -sf --compressed "https://raw.githubusercontent.com/hajimeo/samples/master/bash/$1" -o /tmp/${1}; . /tmp/${1}; }   # not using _$$

_import "utils.sh"
_import "_setup_host.sh"    # functions for Ubuntu OS
_import "setup_work_env.sh" # functions for applicaitons (python, golang, java ...)


function usage() {
    echo "Setup and start service for Log analysis
USAGE:
    $BASH_SOURCE
or
    $BASH_SOURCE -f <f_some_function>

NOTE:
  Global variables start with _ and all capital.
  Local variables also start with _ and all small letters.
"
}


### Global variables for this script ##########################################
: ${_APP_USER:="loganalyser"}
: ${_INST_DIR:="/var/www/${_APP_USER%/}"}


### Executable functions with -f ###############################################


### (supposed to be) private functions #########################################


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

    # Install necessary commands for Ubuntu as root (or sudo)
    f_prepare

    # Create non root user for the application
    f_useradd "${_APP_USER}" || exit $?

    # As this is python based application, setup python for the app user
    sudo -u "${_APP_USER}" -i bash $BASH_SOURCE -f f_setup_python || exit $?
fi