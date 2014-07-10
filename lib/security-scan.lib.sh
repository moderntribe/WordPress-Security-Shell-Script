#!/bin/bash

## WordPress Security Scan Script
## Copyright by Peter Chester of Modern Tribe, Inc.
## Permission to copy and modify is granted under the GPL3 license
## Version 2013.01.11
##
## For more information see:
## http://github.com/moderntribe/WordPress-Security-Shell-Script

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
	CURRENT_DIR=$(pwd)
	cd "$ROOT_DIR"
else
	echo "Error: the directory specified in ROOT_DIR does not exist."
	echo "$ROOT_DIR"
	exit
fi

[ $VERBOSE ] && echo "Running scan on $ROOT_DIR...";

# SVN Scan
if [ -z $BYPASS_SVN ] && [ -d ".svn" ]
then
	[ $VERBOSE ] && echo "Detected SVN environment"

	[ $VERBOSE ] && echo "Cleaning SVN..."
	svn cleanup

	[ $VERBOSE ] && echo "Updating SVN..."
	svn up

	[ $VERBOSE ] && echo "Reverting SVN..."
	svn revert -R .

	[ $VERBOSE ] && echo "Pruning unversioned files..."
	rm -rf `svn status . | grep '^?' | awk '{ print $2 }' | xargs`
fi

# GIT Scan
if [ -z $BYPASS_GIT ] && [ -d ".git" ]
then
	[ $VERBOSE ] && echo "Detected GIT environment"

	if [ $KILL_GITLOCK ] && [ -f ".git/index.lock" ]
	then
		[ $VERBOSE ] && echo "GIT appears to be LOCKED. Deleteing .git/index.lock."
		rm -rf ".git/index.lock"
	fi

	[ $VERBOSE ] && echo "Make sure GIT ignores file perms..."
	git config core.filemode false

	[ $VERBOSE ] && echo "Resetting GIT..."
	git reset --hard HEAD

	[ $VERBOSE ] && echo "Pulling GIT..."
	git pull

	[ $VERBOSE ] && echo "Attempting to update Submodules..."
	git submodule foreach --recursive git reset --hard
	git submodule update --init --recursive

	[ $VERBOSE ] && echo "Cleaning GIT..."
	git clean -df
fi

# Adjusting directory permissions
if [ -z $DIR_PERM ]; then DIR_PERM="755"; fi
[ $VERBOSE ] && echo "Updating file permissions on all directories to be $DIR_PERM"
find "$ROOT_DIR" -type d ! -perm "$DIR_PERM" -exec chmod "$DIR_PERM" {} \;

# Adjust file permissions
if [ -z $FILE_PERM ]; then FILE_PERM="644"; fi
[ $VERBOSE ] && echo "Updating file permissions on all files to be $FILE_PERM"
find "$ROOT_DIR" -type f ! -perm "$FILE_PERM" -exec chmod "$FILE_PERM" {} \;

# Update all file owners
if [ $CODE_OWNER ]
	then
	[ $VERBOSE ] && echo "Update all files to be owned by $CODE_OWNER"
	chown -R "$CODE_OWNER" "$ROOT_DIR"
fi

# Process scrub directories
if [ "$SCRUB_DIRS" ]
	then
	for DIR in ${SCRUB_DIRS[@]}
	do
		# Scan directory
		if [ -d "$DIR" ]
			then
			[ $VERBOSE ] && echo "Scanning and removing PHP files from $DIR..."
			find "$DIR" -name '*php'
			find "$DIR" -name '*php' | xargs rm -rf

			[ $VERBOSE ] && echo "Scanning and removing HTML files from $DIR..."
			find "$DIR" -name '*html'
			find "$DIR" -name '*htm'
			find "$DIR" -name '*html' | xargs rm -rf
			find "$DIR" -name '*htm' | xargs rm -rf

			if [ $WEB_OWNER ]
				then
				[ $VERBOSE ] && echo "Updating file ownership to $WEB_OWNER $DIR..."
				chown -R $WEB_OWNER $DIR
			fi
		else
			echo "Error: $ROOT_DIR/$DIR not found."
		fi
	done
fi

# Process writable directories
if [ "$WRITEABLE_DIRS" ]
	then
	for DIR in ${WRITEABLE_DIRS[@]}
	do
		# Scan directory
		if [ -d "$DIR" ]
			then
			if [ $WEB_OWNER ]
				then
				[ $VERBOSE ] && echo "Updating file ownership to $WEB_OWNER $DIR..."
				chown -R $WEB_OWNER $DIR
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
				[ $VERBOSE ] && echo "Updating file ownership to $WEB_OWNER $WFILE..."
				chown $WEB_OWNER $WFILE
			fi

			[ $VERBOSE ] && echo "Updating file permissions to $FILE_PERM on $WFILE..."
			chmod $FILE_PERM $WFILE
		else
			echo "Error: $ROOT_DIR/$WFILE not found."
		fi
	done
fi

[ $VERBOSE ] && echo "Scan complete!"
cd "$CURRENT_DIR"