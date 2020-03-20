# Cookbooks

Writing a new cookbook? [Chef resources](https://docs.chef.io/resource.html)

The common cookbooks I use to configure boxes. This repo is really designed to be a sub-repo in other repos.

Every cookbook should have a `README.md` file that should tell you how to configure it and what it does (if the name isn't self explanatory enough).


## Tips and Common pitfalls when writing cookbooks

these are things I always forget and have to remember time and time again.


### Chef configuration in Vagrant

* [Vagrant chef configuration options](https://www.vagrantup.com/docs/provisioning/chef_common.html)
* [Other Vagrant chef configuration](https://www.vagrantup.com/docs/provisioning/chef_solo.html)


### Upstart and Vagrant shared folders

If your Upstart script relies on system startup to start your scripts, something like:

    start on (local-filesystems and runlevel [2345])

and your scripts depend on something in one of your repos that Vagrant mounts as a shared folder, then chances are your scripts aren't going to actually start when the Vagrant box is brought up.

There are two solutions, one is to just move the files to a new place, for example, the `spiped` cookbook will move the keys from our repo to `/etc/spiped` on the box so they will be there on machine start.

You can also have your upstart script also listen on `vagrant-mounted` events, this is what the `uwsgi` cookbook does.

    start on ((local-filesystems and runlevel [2345]) or vagrant-mounted)

I evidently prefer the first method since most of the cookbooks ultimately go with that, I did it the other way with `uwsgi` because I forgot about this (which is why it is now in this readme :) )


### /var/run is not permanent storage

I don't know how many times I'm going to need to learn this, but on startup, this directory is cleared, so you can't just have your cookbook create a directory in `/var/run` and set its permissions, you need to actually do it in your upstart script

    pre-start script
        # mode is world executable because evidently you need to execute something to write
        # directory is completely opened because each command could be run under a different user
        mkdir -p -m0777 <%= @run_dir %>
        #chown <%= @username %>:<%= @group %> <%= @run_dir %>
    end script


### Running Chef on Vagrant Manually

    $ cd /tmp/vagrant-chef
    $ chef-client --config solo.rb -j dna.json --local-mode


### Printing out values in recipes

```ruby
require "pp"
pp "======================================================================="
pp node["<RECIPE_NAME>"]
pp "======================================================================="
```


### Changes in Vagrant chef.json not propogating to chef run

Sometimes, when I'm testing cookbooks and so I'm running `vagrant provision` a lot 
the changes I make to the `chef.json` don't seem to propogate, this seems to be because
of a cache file, something like:

```
/tmp/vagrant-chef/f8484c02f82283b9072da693e6402db9/nodes/vagrant-fb4087a6.json
```

That will have the original values of the `/tmp/vagrant-chef/dna.json` file.

Deleting the `vagrant-fb4087a6.json` file seems to fix it.


#### Search

* vagrantfile removing key in chef.json doesn't get rid of value because of node


### Chef OS Environment

```ruby
if platform?('ubuntu') && node['platform_version'].to_f <= 14.04
```
