# Environ Cookbook

hooks for manipulating environments and environment variables

## Attributes

`node["environ"]["global"][:set]` -- a list of global environment variables to set

**NOTE** -- You have to add quotes around values that have spaces, so:

    node["environ"]["global"][:set] = {
      "ENV_NAME" => '"this is a value with spaces"'
    }

`node["environ"]["python"]["sitecustomize"]` -- the path to a python module that will be symbolic linked to the python site-packages directory.

## Resource and Provider

This cookbook creates an `environ` resource and provider that can be used in other cookbooks to set environment variables:

    environ 'ENVIRONMENT_VARIABLE_NAME' do
      value 'environment variable value'
    end

## Platform

Ubuntu 12.04, nothing else has been tested

