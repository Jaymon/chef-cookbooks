# NSQ Cookbook

Install NSQ

## Attributes

`node["nsq"]["version"]` -- The version of NSQ you want to install.

`node["nsq"]["services"]` -- the services you want to start and their names

by default, there are 3 services started: `nsqd`, `nsqlookupd`, and `nsqadmin`.

You can customize them as you see fit:

    node["nsq"]["services"] = {
      'nsqlookupd' => {
        'command' => "nsqlookupd ...",
        'action' => :start
      },
      'nsqd' => {
        'command' => "nsqd ...",
        'action' => :start
      },
      'nsqadmin' => {
        'command' => "nsqadmin ...",
        'action' => :start
      },
    }

You can also add other services from the `bin` directory and they will be Upstarted also.

For each of the defined services, you have the typical Upstart actions for them:

    $ sudo start nsqd
    $ sudo restart nsqd
    $ sudo stop nsqd
    $ sudo status nsqd

## Platform

Ubuntu 12.04, nothing else has been tested

## NSQ Links

* [NSQ source code](https://github.com/bitly/nsq)

* [Docs](http://bitly.github.io/nsq/)

* [Python Docs](https://pynsq.readthedocs.org/en/latest/index.html)

## TODO

add support for tls
