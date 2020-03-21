# Daemon Cookbook

allows you to create systemd managed daemon processes.

## Links

* [RUN MULTIPLE INSTANCES OF THE SAME SYSTEMD UNIT](https://www.stevenrombauts.be/2019/01/run-multiple-instances-of-the-same-systemd-unit/) - This is the layout we use to manage multiple processes


## Configuration block

```ruby
"daemon" => {
  "config" => {
    "environ" => "/path/to/environ.file",
    "username" => "ubuntu",
    "chdir" => "/opt/your_code"
  },
  "services" => {
    "<DAEMON_NAME>" => {
      "desc" => "this will run some thing",
      "command" => "/opt/your_code/your_script.py"
    },
  }
}
```


## Attributes

* `config` -- dict -- these are default options that will be merged into the individual options for each defined daemon under the `services` dict.
* `services` -- dict -- the key is the name of the daemon, which will also be used as the name of the systemd service.

### config block

These are the keys that can be either in the `config` dict, or in each of the individual `services` dict.

* `chdir` -- string -- the base dir that the `command` will execute in.
* `username` -- string -- the user that will execute the `command`.
* `environ` -- string -- an environment file or directory.
* `subscribes` -- [chef specific notifications](http://docs.getchef.com/resource_common.html#subscribes-syntax), it allows you to specify notifications from other chef resources that will trigger the daemon to start, stop, or restart.

	For example, to have all daemons restart if some git repo changes, you could put this in `config`:
	
	```ruby
	"subscribes" => [
	  [:stop, "git[some_repo]", :delayed],
	  [:start, "git[some_repo]", :delayed]
	]
	```

* `desc` -- string -- a description of the daemon.
* `command` -- string -- the command that will be run. Because Systemd is used, the path has to be absolute.
* `count` -- integer -- how many instances of the daemon you want to run.
* `action` -- symbol -- defaults to `:start` but can be set to `:nothing` to have the daemon not be started once configured


## Using

You can start your daemons:

    $ sudo systemctl start <DAEMON_NAME>.target

and you can stop them

    $ sudo systemctl stop <DAEMON_NAME>.target

You have to use `.target` at the end because of how multiple processes are managed by Systemd.

## Platform

Ubuntu 18.04

