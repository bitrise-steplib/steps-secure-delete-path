#!/bin/bash

#
# Run it from the directory which contains step.sh
#

is_verbose=1


# ------------------------
# --- Helper functions ---

function print_and_do_command {
  echo "$ $@"
  $@
}

function inspect_test_result {
  if [ $1 -eq 0 ]; then
    echo "---> [TEST] result: OK"
    test_results_success_count=$[test_results_success_count + 1]
  else
    echo "---> [TEST] result: ERROR"
    test_results_error_count=$[test_results_error_count + 1]
  fi
}

function print_test_header {
  echo
  echo "---> [TEST] $1"
}

#
# First param is the expect message, other are the command which will be executed.
#
function expect_success {
  expect_msg=$1
  shift

  $@
  cmd_res=$?

  if [ $cmd_res -eq 0 ]; then
    if [ $is_verbose -eq 1 ]; then
      echo " -> $expect_msg"
      echo " [OK] Expected zero return code, got: 0"
    fi
  else
    echo " -> $expect_msg"
    echo " [ERROR] Expected zero return code, got: $cmd_res"
    exit 1
  fi
}

#
# First param is the expect message, other are the command which will be executed.
#
function expect_error {
  expect_msg=$1
  shift

  $@
  cmd_res=$?

  if [ ! $cmd_res -eq 0 ]; then
    if [ $is_verbose -eq 1 ]; then
      echo " -> $expect_msg"
      echo " [OK] Expected non-zero return code, got: $cmd_res"
    fi
  else
    echo " -> $expect_msg"
    echo " [ERROR] Expected non-zero return code, got: 0"
    exit 1
  fi
}

function is_dir_exist {
  if [ -d "$1" ]; then
    return 0
  else
    return 1
  fi
}

function is_file_exist {
  if [ -f "$1" ]; then
    return 0
  else
    return 1
  fi
}


# -----------------
# --- Run tests ---

function run_target_command {
  command_arg_path=$1
  print_and_do_command eval "SECURE_DELETE_PATH=\"$command_arg_path\" SECURE_DELETE_WITHSUDO=false ./step.sh"
}

echo "Starting tests..."

testfold_path='testfold'
testfile_path="$testfold_path/testfile.txt"
test_results_success_count=0
test_results_error_count=0


# [TEST] If target file/folder doesn't exist expect error
#  It should return an error if the target doesn't exist
print_test_header "If target file/folder doesn't exist expect error"
(
  test_non_existing_path="this/should/not/exist.ext"
  expect_error "Path $test_non_existing_path should NOT exist" \
    is_dir_exist "$testfold_path"
  expect_error "Path $test_non_existing_path should NOT exist" \
    is_file_exist "$testfold_path"

  # Try remove
  expect_error "should return error for non existing path" \
    run_target_command "$test_non_existing_path"
)
test_result=$?
inspect_test_result $test_result


# [TEST] Create test only file, then securely remove the file
#  It should remove the file
print_test_header "Create test only file, then securely remove the file"
(
  # Create test folder and file
  print_and_do_command mkdir "$testfold_path"
  print_and_do_command echo 'test file content' > "$testfile_path"

  # Both the folder and the file should exist
  expect_success "Folder $testfold_path should exist" \
    is_dir_exist "$testfold_path"
  expect_success "File $testfile_path should exist" \
    is_file_exist "$testfile_path"

  # Remove only the file
  expect_success "The target command should remove only the file, but not the directory" \
    run_target_command "$testfile_path"

  # Expect the folder to still exist, but not the file
  expect_success "Folder $testfold_path should still exist" \
    is_dir_exist "$testfold_path"
  expect_error "File $testfile_path should NOT exist" \
    is_file_exist "$testfile_path"
)
test_result=$?
inspect_test_result $test_result

# [TEST] Create test folder and file, then securely remove the folder
#  It should remove the file and the folder
print_test_header "Create test folder and file, then securely remove the folder"
(
  # Create test folder and file
  print_and_do_command mkdir "$testfold_path"
  print_and_do_command echo 'test file content' > "$testfile_path"

  # Both the folder and the file should exist
  expect_success "Folder $testfold_path should exist" \
    is_dir_exist "$testfold_path"
  expect_success "File $testfile_path should exist" \
    is_file_exist "$testfile_path"

  # Remove the folder
  expect_success "The target command should remove the whole directory, including the file" \
    run_target_command "$testfold_path"

  # Neither the file, nor the folder should exist
  expect_error "Folder $testfold_path should NOT exist" \
    is_dir_exist "$testfold_path"
  expect_error "File $testfile_path should NOT exist" \
    is_file_exist "$testfile_path"
)
test_result=$?
inspect_test_result $test_result

# [TEST] special input paths tests
#  Should properly delete paths with ~ or $SOMEENV
print_test_header "Special input paths tests (~ or $SOMEENV)"
(
  # ~ in the path
  echo 'test file content1' > ~/testfile1.txt
  if [ ! -e ~/testfile1.txt ]; then
    echo " [!] File ~/testfile1.txt should exist!"
  fi
  # remove
  expect_success "The target command should remove ~/testfile1.txt" \
    run_target_command ~/testfile1.txt
  # check
  expect_error "File ~/testfile1.txt should NOT exist" \
    is_file_exist ~/testfile1.txt


  # ENV in the path
  testfile_path2="$HOME/testfile2.txt"
  echo 'test file content2' > "$testfile_path2"
  if [ ! -e "$testfile_path2" ]; then
    echo " [!] File $testfile_path2 should exist!"
  fi
  # remove
  expect_success "The target command should remove $testfile_path2" \
    run_target_command "$testfile_path2"
  # check
  expect_error "File $testfile_path2 should NOT exist" \
    is_file_exist "$testfile_path2"
)
test_result=$?
inspect_test_result $test_result


# --------------------
# --- Test Results ---

echo
echo "--- Results ---"
echo " * Errors: $test_results_error_count"
echo " * Success: $test_results_success_count"
echo "---------------"

if [ $test_results_error_count -eq 0 ]; then
  echo "-> SUCCESS"
else
  echo "-> FAILED"
fi
