#!/bin/bash

## WordPress Security Scan Script
## Copyright by Peter Chester of Modern Tribe, Inc.
## Permission to copy and modify is granted under the GPL2 license
## Last revised 2012-10-03
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
##

# Check for required variables.
REQUIRED_VARS=( "ROOT_DIR" )
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
	CURRENT_DIR=eval pwd
	cd "$ROOT_DIR"
else
	echo "Error: the directory specified in ROOT_DIR does not exist."
	echo "$ROOT_DIR"
	exit
fi

echo "Running scan on $ROOT_DIR..."

# SVN Scan
if [ -z $BYPASS_SVN ] && [ -d ".svn" ]
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
if [ -z $BYPASS_GIT ] && [ -d ".git" ]
then
	echo "Detected GIT environment"

	if [ $KILL_GITLOCK ] && [ f ".git/index.lock" ]
	then
		echo "GIT appears to be LOCKED. Deleteing .git/index.lock."
		rm -rf ".git/index.lock"
	fi

	echo "Resetting GIT..."
	git reset --hard HEAD

	echo "Pulling GIT..."
	git pull

	echo "Attempting to update Submodules..."
	git submodule update --init --recursive
	#git submodule foreach --recursive git pull

	echo "Cleaning GIT..."
	git clean -df
fi

# Adjusting directory permissions
if [ -z $DIR_PERM ]; then DIR_PERM="755"; fi
echo "Updating file permissions on all directories to be $DIR_PERM"
find "$ROOT_DIR" -type d ! -perm "$DIR_PERM" -exec chmod "$DIR_PERM" {} \;

# Adjust file permissions
if [ -z $FILE_PERM ]; then FILE_PERM="644"; fi
echo "Updating file permissions on all files to be $FILE_PERM"
find "$ROOT_DIR" -type f ! -perm "$FILE_PERM" -exec chmod "$FILE_PERM" {} \;

# Update all file owners
if [ $CODE_OWNER ]
	then
	echo "Update all files to be owned by $CODE_OWNER"
	chown "$CODE_OWNER" "$ROOT_DIR" -R
fi

# Process writable directories
if [ "$WRITEABLE_DIRS" ]
	then
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

			if [ $WEB_OWNER ]
				then
				echo "Updating file ownership to $WEB_OWNER $DIR..."
				chown $WEB_OWNER $DIR -R
			fi
		else
			echo "Error: $ROOT_DIR/$DIR not found."
		fi
	done
fi

# Process writable files
if [ "$WRITEABLE_FILES" ]
	then
	for WFILE in ${WRITEABLE_FILES[@]}
	do
		# Scan file
		if [ -f "$WFILE" ]
		then
			if [ $WEB_OWNER ]
				then
				echo "Updating file ownership to $WEB_OWNER $WFILE..."
				chown $WEB_OWNER $WFILE
			fi

			echo "Updating file permissions to $FILE_PERM on $WFILE..."
			chmod $FILE_PERM $WFILE
		else
			echo "Error: $ROOT_DIR/$WFILE not found."
		fi
	done
fi

echo "Scan complete!"
cd "$CURRENT_DIR"