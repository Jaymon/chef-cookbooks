# Repo Cookbook

manage git repos

## Attributes

Each top level key under the `repo` key will be the name of the repo, and have these attributes:

  * dir -- the directory
  * type -- the type of the repo, currently `python` is supported
  * user -- the user to pull the repo
  * branch -- the branch for the repo to pull
  * repo -- the remote repo you want to pull from

So, you would configure it like this (in an environment file):


    default_attributes(
      "repo" => {
        "name_of_repo" => {
          "dir" => base_dir,
          "type" => "python",
          "action" => :sync,
          "user" => username,
          "branch" => branch,
        }
      }
    }

## Platform

Ubuntu 12.04, nothing else has been tested

