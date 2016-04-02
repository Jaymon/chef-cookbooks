# Limits Cookbook

allow setting file descriptor limits

## Attributes

`node["limits"]["fd"]` -- a dict of `username` -> `count` file descriptor limit.

## Example

if you wanted to increase the max allowed file descriptors limit to 100,000 for all users, add this to your configuration:

    'limits' => {
      'fd' => {
        '*' => 100000
      }
    }

## Notes

This only raises file limits for processes started in shells and stuff, if you are trying to raise the limits for upstart managed processes, you need to use the [upstart specific stuff](http://bryanmarty.com/2012/02/10/setting-nofile-limit-upstart/).

## Platform

Ubuntu 12.04, nothing else has been tested

