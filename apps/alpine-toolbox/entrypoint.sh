#!/bin/bash

# Uses /bin/bash if no command is given or the first argument is an option
if [[ ${#@} -eq 0 || ${1:0:1} == '-' ]]; then
	set -- /bin/bash "$@"
fi

# Execute command
exec "$@"
