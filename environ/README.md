# Environ Cookbook

Manipulate environments and environment variables


## Attributes

#### :set

`node["environ"][:set]` -- a hash of global environment variables to set

    node["environ"][:set] = {
      "ENV_NAME_1" => 'this is a value with spaces',
      "ENV_NAME_2" => 'AnotherValue'
    }


#### :file

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


## Resource and Provider

This cookbook creates an `environ` resource and provider that can be used in other cookbooks to set environment variables:

    environ 'ENVIRONMENT_VARIABLE_NAME' do
      value 'environment variable value'
    end

Using the environ resource will also set `ENVIRONMENT_VARIABLE_NAME` in the Ruby environment, so it would be available in Ruby's `ENV` variable. See [here](https://github.com/customink-webops/magic_shell) and [here](http://stackoverflow.com/questions/6284517/how-can-you-use-a-chef-recipe-to-set-an-environment-variable) for more details.


## Tips

### Passing in a raw value

By default, Environ will escape each value so you don't have to worry about manually escaping things like Ampersands and equal signs. This is really handy, but sometimes you might want the raw value to make it all the way to the box, you can do that by setting a special comment above the value in an environment file:


    # environ.raw
    FOO='$([ -n "$FOO" ] && echo $FOO || echo bar)'

The above snippet will pass the unescaped string to the environ and so any time the file is sourced that code will be run and a value will be set for FOO.


## Platform

Ubuntu 14.04


## Notes

Currently, this is limited to "global" environment variables, but [magic shell](https://github.com/customink-webops/magic_shell) could point the way on adding user specific global variables.

