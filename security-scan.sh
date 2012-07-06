#!/bin/bash

## WordPress Security Scan Script
## Copyright 2012 by Peter Chester of Modern Tribe, Inc.
## Permission to copy and modify is granted under the GPL2 license
## Last revised 7/6/2012
##
## DESCRIPTION:
##
## * Uses SVN or GIT to make sure no rogue files exist in an install
## * Removes PHP files from blogs.dir and uploads
## * Removes HTML/HTM files from blogs.dir and uploads
## * Bonus: this effectively acts as a deployment system. Every time you run
##   the script, your version controlled code is deployed.
##
## USAGE:
##
## sh security-scan.sh /path/to/WordPress/install/
##
## It is recommended that you set this up with a cron so that the scan is
## regularly performed. Ideally the script lives outside of your webroot
## directory. The cron would looks something like this:
##
## 0 * * * * sh /path/to/security-scan.sh /path/to/WordPress/install/
##
## This will run the cron once every hour on the hour.
##
## TODO:
##
## * Scan nginx/htaccess files for security
## * Update file permissions
##

# Pass an optional argment to specify a path.
if [ -d $1 ]
then
	cd "$1"
else
	echo "Error: the directory specified does not exist."
	exit
fi

echo "Running scan on $PWD..."

# SVN
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

# GIT
if [ -d ".git" ]
then
	echo "Detected GIT environment"

	echo "Resetting GIT..."
	git reset --hard HEAD

	echo "Pulling GIT..."
	git pull

	echo "Attempting to update Submodules..."
	git submodule update

	echo "Cleaning GIT..."
	git clean -df
fi

# Scan wp-content/uploads
if [ -d "wp-content/uploads" ]
then
	echo "Scanning and removing PHP files from wp-content/uploads..."
	find "wp-content/uploads" -name '*php'
	find "wp-content/uploads" -name '*php' | xargs rm -rf

	echo "Scanning and removing HTML files from wp-content/uploads..."
	find "wp-content/uploads" -name '*html'
	find "wp-content/uploads" -name '*htm'
	find "wp-content/uploads" -name '*html' | xargs rm -rf
	find "wp-content/uploads" -name '*htm' | xargs rm -rf
else
	echo "Error:$PWD/wp-content/uploads not found."
fi

# Scan wp-content/blogs.dir
if [ -d "wp-content/blogs.dir" ]
then
	echo "Scanning and removing PHP files from wp-content/blogs.dir..."
	find "wp-content/blogs.dir" -name '*php'
	find "wp-content/blogs.dir" -name '*php' | xargs rm -rf

	echo "Scanning and removing HTML files from wp-content/blogs.dir..."
	find "wp-content/blogs.dir" -name '*html'
	find "wp-content/blogs.dir" -name '*htm'
	find "wp-content/blogs.dir" -name '*html' | xargs rm -rf
	find "wp-content/blogs.dir" -name '*htm' | xargs rm -rf
else
	echo "Error:$PWD/wp-content/blogs.dir not found."
fi

echo "Scan complete!"