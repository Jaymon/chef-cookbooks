# Sentry Cookbook

Install Sentry

## Attributes

`node["sentry"]["user"]` -- The http user that will run the sentry service

`node["sentry"]["conf_file"]` -- The python configuration file, it will be moved to `/etc/sentry.conf.py`

`node["sentry"]["data_file"]` -- The initial data, this must exist and contain the user and project keys and stuff so that the installation can be automated.

## Managing

You can start and stop sentry using upstart:

    $ sudo start sentry
    $ sudo restart sentry
    $ sudo stop sentry
    $ sudo status sentry

## Platform

Ubuntu 12.04, nothing else has been tested

## Sentry Links

* [Sentry source code](https://github.com/getsentry/sentry)

* [Docs](http://sentry.readthedocs.org/en/latest/index.html)

* [client Docs](http://raven.readthedocs.org/en/latest/index.html)

