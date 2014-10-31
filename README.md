steps-secure-delete-path
========================

Securely deletes the given path (file or folder)

Calls 'rm -rfP the-path' to securely delete the given file or folder.
From the OS X rm man documentation (https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man1/rm.1.html):
Option -P: Overwrite regular files before deleting them.  Files are overwritten three times, first
with the byte pattern 0xff, then 0x00, and then 0xff again, before they are deleted.

This Step is part of the [Open StepLib](http://www.steplib.com/), you can find its StepLib page [here](http://www.steplib.com/step/osx-secure-delete-path)

# Input Enviroment Variables

- **SECURE_DELETE_PATH**

	the path to be deleted
- **SECURE_DELETE_WITHSUDO**

	optional; if set, the path will be deleted using sudo
