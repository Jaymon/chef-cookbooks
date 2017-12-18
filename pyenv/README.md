# Pyenv Cookbook


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

