#!/bin/bash

formatted_output_file_path="$BITRISE_STEP_FORMATTED_OUTPUT_FILE_PATH"

function echo_string_to_formatted_output {
  echo "$1" >> $formatted_output_file_path
}

function write_section_to_formatted_output {
  echo '' >> $formatted_output_file_path
  echo "$1" >> $formatted_output_file_path
  echo '' >> $formatted_output_file_path
}

if [ ! -n "$SECURE_DELETE_PATH" ]; then
  echo '[!] Input $SECURE_DELETE_PATH missing!'
  write_section_to_formatted_output "# Error!"
  write_section_to_formatted_output "Reason: delete target path missing."
  exit 1
fi

# this expansion is required for paths with ~
#  more information: http://stackoverflow.com/questions/3963716/how-to-manually-expand-a-special-variable-ex-tilde-in-bash
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
  write_section_to_formatted_output "Deleting target path using sudo."
else
  echo " (i) NOT using sudo"
  print_and_do_command rm -rfP "$expanded_target_path"
  write_section_to_formatted_output "Deleting target path without using sudo."
fi
write_section_to_formatted_output "# Delete completed!"
exit $?