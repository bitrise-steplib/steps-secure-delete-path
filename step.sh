#!/bin/bash

if [ ! -n "$path" ]; then
  echo '[!] Input $path missing!'
  exit 1
fi

# this expansion is required for paths with ~
#  more information: http://stackoverflow.com/questions/3963716/how-to-manually-expand-a-special-variable-ex-tilde-in-bash
eval expanded_target_path="$path"

is_do_with_sudo=1 # use sudo? default is yes
if [[ -n "$with_sudo" && "$with_sudo" == 'false' ]]; then
  is_do_with_sudo=0
fi

function print_and_do_command {
  echo "$ $@"
  $@
}

echo "Removing $expanded_target_path ..."
if [ $is_do_with_sudo -eq 1 ]; then
  echo " (i) Using sudo"
  print_and_do_command sudo rm -rf "$expanded_target_path"
else
  echo " (i) NOT using sudo"
  print_and_do_command rm -rf "$expanded_target_path"
fi
exit $?
