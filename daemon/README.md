# Daemon Cookbook

allows you to create upstart managed daemon processes.

## Attributes

### The daemon cookbook looks for these attributes

---------

`node["daemon"]["default"]` -- dict -- these are default options that will be merged into the individual options for each defined daemon under `names` dict.

---------

`node["daemon"]["names"]` -- dict -- the key is the name of the daemon, which will also be used as the name of the upstart conf file.

#### Keys

These are the keys that can be either in the `default` dict, or in each of the individual `names` dict.

---------

`dir` -- string -- the base dir that the `command` will execute in.

---------

`username` -- string -- the user that will execute the `command`.

---------

`env` -- string -- an environment file or directory (where all `.sh` files will be read in).

---------

`subscribes` -- [chef specific notifications](http://docs.getchef.com/resource_common.html#subscribes-syntax), it allows you to specify notifications from other chef resources that will trigger the daemon to start, stop, or restart.

For example, to have all daemons restart if some git repo changes, you could put this in `default`:

```ruby
"subscribes" => [
  [:stop, "git[some_repo]", :delayed],
  [:start, "git[some_repo]", :delayed]
]
```

---------

`desc` -- string -- a description of the daemon.

---------

`command` -- string -- the command that the upstart wrapper will run.

---------

`count` -- integer -- how many instances of the daemon you want to run.

---------

`action` -- symbol -- defaults to `:nothing` but can be set to `:start` to have the daemon start once configured


### Example

Let's say our configuration is defined as such:

```ruby
node["daemon"] => {
  "default" => {
    "env" => "/etc/profile.d",
    "username" => "ubuntu",
    "dir" => "/opt/your_code"
  },
  "names" => {
    "some-thing" => {
      "desc" => "this will run some thing",
      "command" => "/opt/your_code/your_script.py"
    },
    "another-thing" => {
      "desc" => "this will run another thing",
      "command" => "/opt/your_code/another_script.sh",
      "count" => 10
    }
  }
}
```

Then the `some-thing` daemon will be configured with:

```ruby
{
  "env" => "/etc/profile.d",
  "username" => "ubuntu",
  "dir" => "/opt/your_code",
  "desc" => "this will run some thing",
  "command" => "/opt/your_code/your_script.py",
}
```

and the `another-thing` daemon will be configured with:

```ruby
{
  "env" => "/etc/profile.d",
  "username" => "ubuntu",
  "dir" => "/opt/your_code",
  "desc" => "this will run another thing",
  "command" => "/opt/your_code/another_script.sh",
  "count" => 10
}
```

## Using

You can start your daemons:

    $ sudo start some-thing
    $ sudo start another-thing

and you can stop them

    $ sudo stop some-thing
    $ sudo stop another-thing

And, if you want to mess with the environment even more, you can pass them in also:

    $ sudo start some-thing PYTHONPATH=some/dir/you/want/to/test

## Logs

Looks like, by default, upstart keeps the logs at:

    /var/log/upstart

## Platform

Ubuntu 12.04

