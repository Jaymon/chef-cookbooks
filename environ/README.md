# Environ Cookbook

Manipulate environments and environment variables.


## Configuration block

```ruby
{
  "environ" => {
    :set => {
      "KEY" => "VALUE",
    },
    :file => [
      "/full/path",
    ],
    "notifies" => [
      [:restart, "resource[RESOURCE_NAME]", :delayed],
    ],
  }
}
```

## Attributes

### :set

`node["environ"][:set]` -- a hash of global environment variables to set

    node["environ"][:set] = {
      "ENV_NAME_1" => 'this is a value with spaces',
      "ENV_NAME_2" => 'AnotherValue'
    }


### :file

`node["environ"][:file]` -- a list of files to merge into the global environment variables

    node["environ"][:file] = [
      '/path/to/first/env/file',
      '/path/to/second/env/file',
    ]


### notifies

`node["environ"]["notifies"] -- a list of services to notify if the environment changes.

    "environ" => {
      "notifies" => [
        [:restart, "service[foo]", :delayed],
      ],
    }


-----------------------------------

## Tips

### Passing in a raw value

By default, Environ will escape each value so you don't have to worry about manually escaping things like Ampersands and equal signs. This is really handy, but sometimes you might want the raw value to make it all the way to the box, you can do that by setting a special comment above the value in an environment file:


    # environ.raw
    FOO='$([ -n "$FOO" ] && echo $FOO || echo bar)'

The above snippet will pass the unescaped string to the environ and so any time the file is sourced that code will be run and a value will be set for FOO.


### File locations

By default, all your environment files are written to `/etc/environ/environ.sh` and a wrapper script is placed in `/etc/profile.d/environ.sh` that handles environment setup for things like bash.

If you would like to use the set environment in other places, you should use the `/etc/environ/environ.sh` file.


## Platform

Ubuntu 18.04


## Notes

Currently, this is limited to "global" environment variables, but [magic shell](https://github.com/customink-webops/magic_shell) could point the way on adding user specific global variables.

