# WordPress Security and GIT/SVN Deployment Script

A shell script for cron based version control deployments and security scans of WordPress.

## Summary

This script was written to quickly and easily set up automated deployment and security scanning of WordPress installs. The idea is that if you have your WordPress install set up on GIT or SVN, you can use this script to regularly update and secure your site(s).

* Uses SVN or GIT to make sure no rogue files exist in an install
* Removes PHP,HTML and HTM files from writable directories such as blogs.dir and uploads.
* Updates and maintains file and folder permissions and ownership.
* Fully configurable.
* Effectively acts as a deployment system. Every time you run the script, your version controlled code is deployed.

Version 2012.10.14

## Important Warning!!!

This script will delete files and folders. If you do not configure your repository and this script correctly you can irreparably damage your website. We are not responsible for catastrophes caused by the mis-use (or use) of this script.

To best ensure that your system does not suffer from damage due to file deletions, make sure that you BACK UP YOUR ENTIRE WEBROOT before running this script.

Also, it is essential that your GIT/SVN ignore configuration is maintained. This script ASSUMES THAT UNVERSIONED FILES THAT ARE NOT IGNORED SHOULD BE DELETED.

For example, it is essential that at a minimum, the following is in your ignore configuration:

* wp-config.php
* wp-content/uploads

Depending on your configuration, you may also need to ignore other files & folders such as .htaccess, wp-content/cache, wp-content/blogs.dir, wp-content/advanced-cache.php, etc...

## Usage

`bash mydomain.security-scan.sh`

In some cases, 'bash' doesn't work and in stead you would invoke the script like this:

`. mydomain.security-scan.sh`

It is recommended that you set this up on a crontab so that the scan is regularly performed. Ideally the script lives outside of your webroot directory. See installation for more details.

## Todo

* Possibly scan wp-config.php and .htaccess for security
* Possibly update the lib script to also accept parameters as arguments so that the config file is optional and the lib script can be executed directly.

## Installation

These instructions assume that you have basic *nix systems skills. If you read through this and feel totally confused, then you should probably seek some professional help in installing this.

Although this script is flexible enough to be configured and used in a variety of ways. Here's how we prefer to install it:

# Install your Versioned Code

Before we do anything with this script, we're making some assumptions about your code setup. In particular, we're assuming that you've got your WordPress code in either GIT or SVN version control and that you've checked out that code into your webroot on your server.

As per our Important Warning above, we're also assuming that you've got proper GIT/SVN ignore configurations so that when the site is running, there are NO UNVERSIONED FILES aside from ones that you've explicitly ignored.

This script supports traditional WordPress configurations as well as @markjaquith's Skeleton configuration.

# Download the Script onto Your Server

Change directories to the folder above the webroot.

`cd /path/above/your/webroot`

Make a folder called scripts to hold this script and any others you might want to run.

`mkdir scripts`

Change directories to your scripts folder.

`cd scripts`

Initialize GIT.

`git init`

Checkout the security scripts code.

`git checkout git://github.com/moderntribe/WordPress-Security-Shell-Script.git security-script`

# Set up a Local Config

While still in the scripts folder, copy the sample script to a new file that you can configure for your website.

`cp security-script/security-scan.config.sample.sh mydomain.security-scan.sh`

Edit the file (I prefer to use Nano for this. You can choose to use whatever or even FTP and use your favorite file editor). The various configuration options are documented in the sample config file.

`nano mydomain.security-scan.sh`

Define at least ROOT_DIR, WRITEABLE_DIRS and the last line in the script where we include the library. You might also want to define KILL_GITLOCK as true to ensure that this script never gets locked out of making GIT updates.

# Test the Script

Backup your webroot incase the script messes things up.

`cp -rfp /path/to/your/webroot /path/to/your/webroot.bk`

Run the script (not this should be running the copy you made).

`bash /path/above/your/webroot/scripts/mydomain.security-scan.sh`

# Set up a Crontab

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

This code is unsupported and offered on an "as is" basis. If you would like support we recommend either asking about it on [Stack Overflow](http://stackoverflow.com/search?q=wordpress+security+scan) or entering an issue on [the github tracker](https://github.com/moderntribe/WordPress-Security-Shell-Script/issues)