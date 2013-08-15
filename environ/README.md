# Environ Cookbook

hooks for manipulating environments and environment variables

## Attributes

`node["environ"]["global"][:set]` -- a hash of global environment variables to set

**NOTE** -- You have to add quotes around values that have spaces, so:

    node["environ"]["global"][:set] = {
      "ENV_NAME" => '"this is a value with spaces"'
    }

`node["environ"]["global"][:file]` -- a list of files to merge into the global environment variables

    node["environ"]["global"][:file] = [
      '/path/to/first/env/file',
      '/path/to/second/env/file',
    ]

`node["environ"]["python"]["sitecustomize"]` -- the path to a python module that will be symbolic linked to the python site-packages directory.

`node["environ"]["python"]["usercustomize"]` -- a hash of `username => path to module` that will be symbolic linked to the user's user site directory.

## Resource and Provider

This cookbook creates an `environ` resource and provider that can be used in other cookbooks to set environment variables:

    environ 'ENVIRONMENT_VARIABLE_NAME' do
      value 'environment variable value'
    end

Using the environ resource will also set `ENVIRONMENT_VARIABLE_NAME` in the Ruby environment, so it would be available in Ruby's `ENV` variable. See [here](https://github.com/customink-webops/magic_shell) and [here](http://stackoverflow.com/questions/6284517/how-can-you-use-a-chef-recipe-to-set-an-environment-variable) for more details.

## Platform

Ubuntu 12.04, nothing else has been tested

## Notes

Currently, this is limited to "global" environment variables, but [magic shell](https://github.com/customink-webops/magic_shell) could point the way on adding user specific global variables.

