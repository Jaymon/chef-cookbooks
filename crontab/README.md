# Crontab Cookbook

manage crontabs

## Attributes

`node["crontab"]["env"]` -- string -- a directory or file to be sourced in the crontab to set environment. I like to use the `/etc/profile.d` directory.

`node["crontab"]["users"]` -- dict -- each key will be a username, with a dict value that will be of the form:

    "cron_name" => {
      "dir" => "/path/to/directory/cron/should/run/in",
      "command" => 'echo Hi Mom', # the actual command you want to run
      "schedule" => "* * * * *",
    }


So, you would configure the crontab like this (in an environment file):

    default_attributes(
      "crontab" => {
        "env" => "/etc/profile.d",
        "users" => {
          "username" => {
            "cron_name" => {
              "dir" => "/path/to/directory/cron/should/run/in",
              "command" => 'echo Foo',
              "schedule" => "0 * * * *",
            },
            "cron_name_2" => {
              "dir" => "/path/to/directory/cron/should/run/in",
              "command" => 'echo Bar',
              "schedule" => "5 * * * *",
            }
          },
          "username2" => {...}
        }
      }
    )

## Platform

Ubuntu 12.04, nothing else has been tested

