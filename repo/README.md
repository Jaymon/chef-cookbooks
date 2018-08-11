# Repo Cookbook

manage git repos


## Attributes

Each top level key under the `repo` key will be the name of the repo, and have these attributes:

  * dir -- the directory
  * type -- the type of the repo, currently `python` is supported
  * user -- the user to pull the repo
  * branch -- the branch for the repo to pull
  * repo -- the remote repo you want to pull from
  * notifies -- list of lists, if you want [to notify other listeners when the code changes](https://docs.chef.io/resource_common.html#notifications) you can use this key

So, you would configure it like this (in an environment file):


    default_attributes(
      "repo" => {
        "name_of_repo" => {
          "dir" => base_dir,
          "repo" => 'git@something.git',
          "type" => "python",
          "user" => username,
          "branch" => branch,
          "notifies" => [
            [:action, "resource[name]", :timer]
          ],
        }
      }
    }

So, for example, if you were going to restart uwsgi when a [repo](https://github.com/Jaymon/chef-cookbooks/tree/master/repo) changed, you could configure the `notifies` block like this:

    "notifies" => [
      [:restart, "service[service_name]", :delayed]
    ]

Every repo will also be available for listeners in other recipes using:

    git[name_of_repo]

That way you can have other recipes listen for changes to whatever dir and restart services or something.


## Platform

Ubuntu 12.04, nothing else has been tested

