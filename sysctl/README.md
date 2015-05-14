# Sysctl Cookbook

Kernel and startup configuration


## Attributes

### basename

This usually doesn't need to be messed with, it determines the name of the file that's placed in all the directories.

### :set

These are key/value pairs that will be put into a file placed in `/etc/sysctl.d/`.

### :run

contains a list of commands that will be placed into an Upstart file that runs on startup.


## Example

```ruby
"sysctl" => {
  :set => {
    "vm.overcommit_memory" => 1,
    "net.core.somaxconn" => 1024,
    "net.ipv4.tcp_mem" => "98304 131072 196608",
  },
  :run => [
    "echo never > /sys/kernel/mm/transparent_hugepage/enabled",
  ]
}
```


## Other stuff

If you want to make sure your settings took, you can run:

    $ sysctl --all

If you want a more full featured, better supported, chef cookbook, you can use [this one](https://supermarket.chef.io/cookbooks/sysctl).


## Platform

Ubuntu 14.04, nothing else has been tested

