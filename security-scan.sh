#!/bin/bash

## WordPress Security Scan Script
## Executable Config File
##
## Copy and modify this file with the following variables and execute this
## file manually or via cron to run the script. Ideally you'll want to run
## this as root using 'sudo'. For more information see:
## http://github.com/moderntribe/WordPress-Security-Shell-Script
##
## This file can be placed anywhere on your server as long as the references
## back to the ROOT_DIR and the library (last line) are absolute.


# Root web directory. This is the full path to your WordPress root folder.

ROOT_DIR="/absolute/path/to/the/web/root/folder"


# Optional list of all PHP writeable directories. These directories will be
# purged of PHP, HTML, and HTM files and their file permissions will be
# updated such that PHP can write to the files. Note that scrip array items
# are separated by spaces, not commas.

# WRITEABLE_DIRS=( "wp-content/uploads" "wp-content/blogs.dir" "wp-content/cache" )


# Optional list of all PHP writeable files. These files will have their file
# permissions updated such that PHP can write to them. Note that scrip array
# items are separated by spaces, not commas.

# WRITEABLE_FILES=( "wp-config.php" "wp-content/advanced-cache.php" "wp-content/cache-config.php" )


# Optional PHP writeable user:group. This should be whatever the user:group
# is that PHP is using otherwise php may be unable to write to the files and
# folders.

# WEB_OWNER="www-data:www-data"


# Optional private code user:group. In some cases, such as on many shared
# hosting environments, this is the same as the writeable user:group setting.
# But ideally, we want to make code files inaccessible to PHP so that hackers
# are prevented from gaining access to functional files.

# CODE_OWNER="www:www"


# Optional permissions for directories (defaults to 755).

# DIR_PERM="755"


# Optional permissions for files (defaults to 644).

# FILE_PERM="644"


# Optional flag to skip SVN processing. If there are no .svn files in your
# code, SVN will be skipped anyway. But if for some reason you want to
# explicitely bypass SVN updating and resetting, then you can set this to
# true.

# BYPASS_SVN=true


# Optional flag to skip GIT processing. If there are no .git files in your
# code, GIT will be skipped anyway. But if for some reason you want to
# explicitely bypass GIT updating and resetting, then you can set this to
# true.

# BYPASS_GIT=true


# Optional flag to kill GIT locking. Sometimes, we've encountered a case where
# GIT is locked and we can no longer use this script to update or reset git.
# To prevent this, we've implemented a crude workaround of forcing a removal
# of the lock file. Caution: it is possible that removing this lock file while
# a legitimate GIT process is running may corrupt your repository. You should
# only use this option if you are sure that noone is manually pulling from git
# and that there is no chance of another GIT process running when this script
# runs.

# KILL_GITLOCK=true


# Include the actual script (use the full path). Up to this point all we've
# been doing is configuring the script. All this configuration will do nothing
# if you don't actually then run the script :)

. /absolute/path/to/this/folder/lib/security-scan.lib.sh