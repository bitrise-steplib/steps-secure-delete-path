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

function determine_os_type {
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     os_type=Linux;;
      Darwin*)    os_type=Mac;;
      *)          os_type="UNKNOWN:${unameOut}"
  esac
}

function print_and_do_command {
  echo "$ $@"
  $@
}

determine_os_type
case "${os_type}" in
    Linux*)     os_specific_switches="";;
    Mac*)       os_specific_switches="-P";;
    *)          os_specific_switches=""
esac

echo "OS type: $os_type"
echo "Removing $expanded_target_path ..."
if [ $is_do_with_sudo -eq 1 ]; then
  echo " (i) Using sudo"
  print_and_do_command sudo rm -rf ${os_specific_switches} "$expanded_target_path"
else
  echo " (i) NOT using sudo"
  print_and_do_command rm -rf ${os_specific_switches} "$expanded_target_path"
fi
exit $?