#!/bin/bash

## WordPress Security Scan Script
## Copyright by Peter Chester of Modern Tribe, Inc.
## Permission to copy and modify is granted under the GPL2 license
## Last revised 2012-09-27
##
## DESCRIPTION:
##
## * Uses SVN or GIT to make sure no rogue files exist in an install
## * Removes PHP files from blogs.dir and uploads
## * Removes HTML/HTM files from blogs.dir and uploads
## * Updates file and folder permissions and ownership
##
## * Bonus: this effectively acts as a deployment system. Every time you run
##   the script, your version controlled code is deployed.
##
## USAGE:
##
## sudo bash security-scan.sh
##
## It is recommended that you set this up with a cron so that the scan is
## regularly performed. Ideally the script lives outside of your webroot
## directory. The cron would looks something like this:
##
## */5 * * * * bash /path/to/security-scan.sh
##
## This will run the cron once every 5 minutes.
##
## TODO:
##
## * Scan nginx/htaccess files for security
## * Update permissions scan to ignore files with correct perms
##

# Check for required variables.
REQUIRED_VARS=( "ROOT_DIR" "WRITEABLE_DIRS" "WRITEABLE_FILES" "WEB_OWNER" "CODE_OWNER" )
for REQUIRED_VAR in ${REQUIRED_VARS[@]}
do
	# Test that vars are set
	REQUIRED_VAR_TEST=$(eval echo "\$${REQUIRED_VAR}")
	if [ -z "${REQUIRED_VAR_TEST+x}" ]
	then
		echo "ERROR: '$REQUIRED_VAR' is required."
		exit
	fi
done

# Change directories to the webroot (ROOT_DIR).
if [ -d $ROOT_DIR ]
then
	cd "$ROOT_DIR"
else
	echo "Error: the directory specified in ROOT_DIR does not exist."
	echo "$ROOT_DIR"
	exit
fi

echo "Running scan on $PWD..."

# SVN Scan
if [ -d ".svn" ]
then
	echo "Detected SVN environment"

	echo "Cleaning SVN..."
	svn cleanup

	echo "Updating SVN..."
	svn up

	echo "Reverting SVN..."
	svn revert -R .

	echo "Pruning unversioned files..."
	rm -rf `svn status . | grep '^?' | awk '{ print $2 }' | xargs`
fi

# GIT Scan
if [ -d ".git" ]
then
	echo "Detected GIT environment"

	if [ -f ".git/index.lock" ]
	then
		echo "GIT appears to be LOCKED. Deleteing .git/index.lock."
		rm -rf ".git/index.lock"
	fi

	echo "Resetting GIT..."
	git reset --hard HEAD

	echo "Pulling GIT..."
	git pull

	echo "Attempting to update Submodules..."
	git submodule init
	git submodule update

	echo "Cleaning GIT..."
	git clean -df
fi

# Adjusting directory permissions
if [ -z ${DIR_PERM} ]; then DIR_PERM="755"; fi
echo "Updating file permissions on all directories to be $DIR_PERM"
find "$PWD" -type d ! -perm "$DIR_PERM" -exec chmod "$DIR_PERM" {} \;

# Adjust file permissions
if [ -z ${FILE_PERM} ]; then FILE_PERM="644"; fi
echo "Updating file permissions on all files to be $FILE_PERM"
find "$PWD" -type f ! -perm "$FILE_PERM" -exec chmod "$FILE_PERM" {} \;

# Update all file owners
echo "Update all files to be owned by $CODE_OWNER"
chown $CODE_OWNER "$PWD" -R

# Process writable directories
for DIR in ${WRITEABLE_DIRS[@]}
do
	# Scan directory
	if [ -d "$DIR" ]
	then
		echo "Scanning and removing PHP files from $DIR..."
		find "$DIR" -name '*php'
		find "$DIR" -name '*php' | xargs rm -rf

		echo "Scanning and removing HTML files from $DIR..."
		find "$DIR" -name '*html'
		find "$DIR" -name '*htm'
		find "$DIR" -name '*html' | xargs rm -rf
		find "$DIR" -name '*htm' | xargs rm -rf

		echo "Updating file ownership to $WEB_OWNER $DIR..."
		chown $WEB_OWNER $DIR -R
	else
		echo "Error: $PWD/$DIR not found."
	fi
done

# Process writable files
for WFILE in ${WRITEABLE_FILES[@]}
do
	# Scan file
	if [ -f "$WFILE" ]
	then
		echo "Updating file ownership to $WEB_OWNER $WFILE..."
		chown $WEB_OWNER $WFILE

		echo "Updating file permissions to 755 on $WFILE..."
		chmod 755 $WFILE
	else
		echo "Error: $PWD/$WFILE not found."
	fi
done

echo "Scan complete!"