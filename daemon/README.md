# Daemon Cookbook

allows you to create systemd managed daemon processes.

## Links

* [RUN MULTIPLE INSTANCES OF THE SAME SYSTEMD UNIT](https://www.stevenrombauts.be/2019/01/run-multiple-instances-of-the-same-systemd-unit/) - This is the layout used to manage multiple processes


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


Basically, each `services` dict block is merged with the global `config` block and that's what is used to setup the `<DAEMON_NAME>` daemon.


### configuration blocks

These are the keys that can be either in the `config` dict, or in each of the individual `services` dict blocks.

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
* `verify` -- boolean -- defaults to `true` which means all commands have to be valid and files have to exist. Sometimes you are creating a daemon for something that might not exist yet so set this to `false`. From [the docs](https://docs.chef.io/resources/systemd_unit/#unit-file-verification):

    > Specifies if the unit will be verified before installation. Systemd can be overly strict when verifying units, so in certain cases it is preferable not to verify the unit. The unit file is verified using a `systemd-analyze verify` call before being written to disk. Be aware that the referenced commands and files need to already exist before verification.


## Using

You can start your daemons:

    $ sudo systemctl start <DAEMON_NAME>.target

and you can stop them

    $ sudo systemctl stop <DAEMON_NAME>.target

You have to use `.target` at the end because of how multiple processes are managed by Systemd.

You can tail the output of any of the processes:

    $ sudo journalctl -f -u <DAEMON_NAME>@<N>.service


## Platform

Ubuntu 18.04

