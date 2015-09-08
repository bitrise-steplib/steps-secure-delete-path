# Secure Delete Path

The new Secure Delete Path step.

Securely deletes the given path (file or folder)

Calls 'rm -rfP the-path' to securely delete the given file or folder.
From the OS X rm man documentation (https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man1/rm.1.html):
Option -P: Overwrite regular files before deleting them.  Files are overwritten three times, first
with the byte pattern 0xff, then 0x00, and then 0xff again, before they are deleted.


Can be run directly with the [bitrise CLI](https://github.com/bitrise-io/bitrise),
just `git clone` this repository, `cd` into it's folder in your Terminal/Command Line
and call `bitrise run test`.

*Check the `bitrise.yml` file for required inputs which have to be
added to your `.bitrise.secrets.yml` file!*
