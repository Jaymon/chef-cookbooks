# Package Cookbook

Install packages

## Attributes

`node["package"]["check_file"]` -- for `package::update`, will only run `apt-get update` if this file does not exist

So if you wanted to only update the repo on the first run of chef:

    node["package"]["check_file"] = '/tmp/first-run-only'

the `package::update` will create the file after running.

`node["package"][:install]` -- a list of packages to install

`node["package"][:update]` -- a list of packages to update

`node["package"][:remove]` -- a list of packages to remove

`node["package"][:purge]` -- a list of packages to purge

So if you wanted to install a few packages, and update some others on each run:

    node["package"] = {
      :install => ["foo", "bar"],
      :update => ["che"]
    }

## Platform

Ubuntu 12.04, nothing else has been tested

If you need a more full featured apt cookbook,
use the [Official Opscode Apt Cookbook](https://github.com/opscode-cookbooks/apt).

