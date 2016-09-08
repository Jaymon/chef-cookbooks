# Package Cookbook

Install and manage packages.


## Recipes


### package

Runs `package::update` and then installs any configured packages using these attributes:

`node["package"][:install]` -- a list of packages to install

`node["package"][:update]` -- a list of packages to update

`node["package"][:remove]` -- a list of packages to remove

`node["package"][:purge]` -- a list of packages to purge

So if you wanted to install a few packages, and update some others on each run:

    node["package"] = {
      :install => ["foo", "bar"],
      :update => ["che"]
    }


### package::update

This basically runs `apt-get update`, it uses the `check_file` attribute to decide whether it should run:

`node["package"]["check_file"]` -- for `package::update`, will only run `apt-get update` if this file does not exist

So if you wanted to only update the repo on the first run of chef:

    node["package"]["check_file"] = '/tmp/first-run-only'

the `package::update` will create the file after running.


### package::upgrade

From the [apt-get manual](http://manpages.ubuntu.com/apt-get.8)

```
upgrade
   upgrade is used to install the newest versions of all packages
   currently installed on the system from the sources enumerated in
   /etc/apt/sources.list. Packages currently installed with new
   versions available are retrieved and upgraded; under no
   circumstances are currently installed packages removed, or packages
   not already installed retrieved and installed. New versions of
   currently installed packages that cannot be upgraded without
   changing the install status of another package will be left at
   their current version. An update must be performed first so that
   apt-get knows that new versions of packages are available.
```

Uses the `check_upgrade` attribute to specify a file on how often it gets run (when the file doesn't exist it runs and then creates the file, when it does exist, this will not run.


### package::dist_upgrade

From the [apt-get manual](http://manpages.ubuntu.com/apt-get.8)

```
dist-upgrade
   dist-upgrade in addition to performing the function of upgrade,
   also intelligently handles changing dependencies with new versions
   of packages; apt-get has a "smart" conflict resolution system, and
   it will attempt to upgrade the most important packages at the
   expense of less important ones if necessary. So, dist-upgrade
   command may remove some packages. The /etc/apt/sources.list file
   contains a list of locations from which to retrieve desired package
   files. See also apt_preferences(5) for a mechanism for overriding
   the general settings for individual packages.
```

Uses the `check_dist_upgrade` attribute, which is similar to `check_file` and `check_upgrade`.


## Platform

Ubuntu 14.04, nothing else has been tested

If you need a more full featured apt cookbook,
use the [Official Opscode Apt Cookbook](https://github.com/opscode-cookbooks/apt).


## Links

http://askubuntu.com/questions/222348/what-does-sudo-apt-get-update-do

http://askubuntu.com/questions/81585/what-is-dist-upgrade-and-why-does-it-upgrade-more-than-upgrade

http://askubuntu.com/questions/44122/how-to-upgrade-a-single-package-using-apt-get

