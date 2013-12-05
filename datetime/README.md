# Datetime Cookbook

Setup the date and time on the server

## Attributes

`node["datetime"]["timezone"]` -- the timezone the server should use (default UTC)

## Platform

Ubuntu 12.04, nothing else has been tested

## TO ADD

ntp recipe

## Other

If you ever need to set the timezone by hand:

    sudo dpkg-reconfigure tzdata
