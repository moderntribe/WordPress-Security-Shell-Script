# WordPress Security and GIT/SVN Deployment Script

A shell script for cron based version control deployments and security scans of WordPress.

## Summary
This script was written to quickly and easily set up automated deployment and security scanning of WordPress installs. The idea is that if you have your WordPress install set up on GIT or SVN, you can use this script to regularly update and secure your site(s).

## Installation
These instructions assume that you have basic *nix systems skills. If you read through this and feel totally confused, then you should probably seek some professional help in installing this.

Although this script is flexible enough to be configured and used in a variety of ways. Here's how we prefer to install it:

# Put the Script on Your Server

Change directories to the folder above the webroot.

`cd /path/above/your/webroot`

Make a folder called scripts to hold this script and any others you might want to run.

`mkdir scripts`

Change directories to your scripts folder.

`cd scripts`

Initialize GIT.

`git init`

Checkout the security scripts code.

`git checkout git://github.com/peterchester/WordPress-Security-Shell-Script.git security-script`

# Set up a config

While still in the scripts folder, copy the sample script to a new file that you can configure for your website.

`cp security-script/security-scan.sh mydomain.security-scan.sh`

Edit the file (I prefer to use Nano for this. You can choose to use whatever or even FTP and use your favorite file editor)

`nano mydomain.security-scan.sh`

Define at least ROOT_DIR, WRITEABLE_DIRS and the last line in the script where we include the library. You might also want to define KILL_GITLOCK as true to ensure that this script never gets locked out of making GIT updates.

# Test the script

Backup your webroot incase the script messes things up.

`cp -rfp /path/to/your/webroot /path/to/your/webroot.bk`

Run the script (not this should be running the copy you made).

`bash /path/above/your/webroot/scripts/mydomain.security-scan.sh`

# Set up a crontab

Open your cron for editing:

`crontab -e`

Run this every 5 minutes or so. You can also choose to output the results to a log file.

*/5 * * * * bash /path/above/your/webroot/scripts/mydomain.security-scan.sh > /dev/null 2>&1

## License
Copyright Modern Tribe, Inc. (@moderntribeinc) 2012

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).

## Authors and Contributors
Authored by Chaim Peter Chester (@peterchester) with contributions from Daniel Dvorkin (@mzaweb) and Jonathan Brinley (@jbrinley).

## Support or Contact
This code is unsupported and offered on an "as is" basis. If you would like support we recommend either asking about it on [Stack Overflow](http://stackoverflow.com/search?q=wordpress+security+scan) or entering an issue on [the github tracker](https://github.com/peterchester/WordPress-Security-Shell-Script/issues)