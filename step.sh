#!/bin/bash

if [ ! -n "$SECURE_DELETE_PATH" ]; then
	echo '[!] Input $SECURE_DELETE_PATH missing!'
	exit 1
fi

function print_and_do_command {
  echo "$ $@"
  $@
}

print_and_do_command rm -rfP "$SECURE_DELETE_PATH"
exit $?