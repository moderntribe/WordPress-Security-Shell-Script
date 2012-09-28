#!/bin/bash

## WordPress Security Scan Script
## Executable Config File
##
## Copy and modify this file with the following variables and execute this
## file manually or via cron to run the script. Ideally you'll want to run
## this as root using 'sudo'.
##
## This file can be placed anywhere on your server as long as the references
## back to the ROOT_DIR and the library (last line) are absolute.
##

# Root web directory
ROOT_DIR="/absolute/path/to/the/web/root/folder"

# List of all PHP writeable directories
WRITEABLE_DIRS=( "relative/path1" "relative/path2" "etc..." )

# List of all PHP writeable files
WRITEABLE_FILES=( "relative/file/path1.txt" "realtive/file/path2.txt" "etc..." )

# PHP writeable user:group - this should be whatever the user:group is that PHP is using
WEB_OWNER="www-data:www-data"

# Private code user:group
CODE_OWNER="www:www"

# Permissions for directories (defaults to 755)
DIR_PERM="755"

# Permissions for files (defaults to 644)
FILE_PERM="644"

# Include the actual script (use the full path)
source /absolute/path/to/this/folder/lib/security-scan.lib.sh