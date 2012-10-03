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

# Optional list of all PHP writeable directories
# WRITEABLE_DIRS=( "relative/path1" "relative/path2" "etc..." )

# Optional list of all PHP writeable files
# WRITEABLE_FILES=( "relative/file/path1.txt" "realtive/file/path2.txt" "etc..." )

# Optional PHP writeable user:group - this should be whatever the user:group is that PHP is using
# WEB_OWNER="www-data:www-data"

# Optional private code user:group
# CODE_OWNER="www:www"

# Optional permissions for directories (defaults to 755)
# DIR_PERM="755"

# Optional permissions for files (defaults to 644)
# FILE_PERM="644"

# Optional flag to skip SVN processing
# BYPASS_SVN=true

# Optional flag to skip GIT processing
# BYPASS_GIT=true

# Optional flag to kill GIT locking
# KILL_GITLOCK=true

# Include the actual script (use the full path)
. /absolute/path/to/this/folder/lib/security-scan.lib.sh