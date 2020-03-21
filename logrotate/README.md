# Logrotate Cookbook

Hooks for installing and manipulating logrotate.


## Attributes

configuration is under the `logrotate` namespace.

### Keys

#### :merge

    "name" => {
      "/var/log/name/*.log" => {
        "rotate" => 5000
      }
    }

Using `:merge` you can specify values to be merged into already existing logrotate configuration, and if the configuration doesn't exist, then your merge changes will be silently ignored.

#### :set

Similar to merge, except it will completely relplace configuration for the given config file paths, or it will add them if they don't exist.


## Platform

Ubuntu 14.04, it will probably work on Ubuntu >=12.04, but we use it on 14.04.

## Other

Some of the best tutorials on Logrotate I've found:

* http://www.rackspace.com/knowledge_center/article/understanding-logrotate-utility
* http://www.rackspace.com/knowledge_center/article/sample-logrotate-configuration-and-troubleshooting

