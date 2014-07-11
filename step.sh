#!/bin/bash

if [ ! -n "$SECURE_DELETE_PATH" ]; then
  echo '[!] Input $SECURE_DELETE_PATH missing!'
  exit 1
fi

# this expansion is required for paths with ~
eval expanded_target_path="$SECURE_DELETE_PATH"

is_do_with_sudo=1 # use sudo? default is yes
if [[ -n "$SECURE_DELETE_WITHSUDO" && "$SECURE_DELETE_WITHSUDO" == 'false' ]]; then
  is_do_with_sudo=0
fi

function print_and_do_command {
  echo "$ $@"
  $@
}

echo "Removing $expanded_target_path ..."
if [ $is_do_with_sudo -eq 1 ]; then
  echo " (i) Using sudo"
  print_and_do_command sudo rm -rfP "$expanded_target_path"
else
  echo " (i) NOT using sudo"
  print_and_do_command rm -rfP "$expanded_target_path"
fi
exit $?