# Pyenv Cookbook

Installs [Pyenv](https://github.com/pyenv/pyenv/) globally, each user of the system can then install any versions they want to use and those versions should be managed separately. So user `foo` could install `3.8.1` and install a bunch of packages and user `bar` could also install `3.8.1` and install different packages and they shouldn't clobber each other.


## Attributes

`node["pyenv"]["versions"]` -- dict -- each key will be a username, with a dict value will be a list of python versions to install:

    "pyenv" => {
      "versions" => {
        "USERNAME" => [
          "3.6.3",
          "2.7.14",
        ]
      }
    },


## Platform

Ubuntu 14.04, nothing else has been tested

