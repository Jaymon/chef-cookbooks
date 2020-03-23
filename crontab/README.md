# Crontab Cookbook

manage crontabs


## Configuration block

```ruby
"crontab" => {
	"environ" => "/etc/profile.d",
	"users" => {
	  "<USERNAME 1>" => {
	    "<CRON NAME 1>" => {
	      "chdir" => "/path/to/directory/cron/should/run/in",
	      "command" => 'echo Foo',
	      "schedule" => "0 * * * *",
	    },
	    "<CRON NAME 2>" => {
	      "chdir" => "/path/to/directory/cron/should/run/in",
	      "command" => 'echo Bar',
	      "schedule" => "5 * * * *",
	    }
	  },
	  "<USERNAME 2>" => {...}
	}
}
```


## Attributes

### environ

string -- a directory or file to be sourced in the crontab to set environment. This can be overridden per cron job.


### chdir

string -- the directory that `command` will run in.


### logfile

string -- the path you want output of `command` written to. If this is not specified then it will default to `/var/log/crontab/<USERNAME>-<CRON NAME>.log`.


### users

dict -- each key will be a username, with a dict value that will be of the form:

    "<CRON NAME>" => {
      "chdir" => "/path/to/directory/cron/should/run/in",
      "command" => 'echo Hi Mom', # the actual command you want to run
      "schedule" => "* * * * *",
    }


## Cron scheduling format

Because I can never remember:

      *    *    *    *    *      command to be executed
      -    -    -    -    -
      |    |    |    |    |
      |    |    |    |    +----- day of week (0 - 6) (Sunday=0)
      |    |    |    +------- month (1 - 12)
      |    |    +--------- day of month (1 - 31)
      |    +----------- hour (0 - 23)
      +------------- min (0 - 59)


## Removing Cron Jobs

The recipe will try and remove any stray cron jobs after you've removed or commented out from the configuration, but in order to do that it needs to know there were cron jobs there in the first place, so if you are removing all your cron jobs you need to leave the `users` dict with the `username` keys intact:

      "crontab" => {
        "users" => {
          "username" => {}
        }
      }

Otherwise the cron jobs will remain even though they've been removed in your configuration


## Platform

Ubuntu 18.04, nothing else has been tested

