# App Cookbook

set up app specific environments

## Attributes

### The app::services recipe looks for these attributes

`node["app"]['services']["names"]` -- dict -- each key is the name of the service, each value is a dict with these keys:

* base_dir -- the chdir directory for the api application base directory
* command -- the command to start an api instance
* instances -- how many api instances you want running

-------------------------------------------------------------------------------

### The app::ops recipe looks for these attributes

`node["app"]['ops']["base_dir"]` -- the chdir directory for the ops application base directory

-------------------------------------------------------------------------------

### The app::user recipe looks for these attributes

`node["app"]['user']["username"]` -- the username of the app user we want to have

## Using

The api, admin, and chat http handlers are managed via Upstart, so you can start them:

    $ sudo start apis
    $ sudo start chats

and you can stop them

    $ sudo stop apis
    $ sudo stop chats

If you want to verify the handlers are running:

    $ ps aux | grep python

and you should see `api.py` or `chat.py` handlers running.

You can fire up a test api (or chat) instance manually:

    $ sudo start api N=test

And, if you want to mess with the environment variables, you can pass them in also:

    $ sudo start api N=test PYTHONPATH=some/dir/you/want/to/test

## Logs

Looks like, by default, upstart keeps the logs at:

    /var/log/upstart

So, to see the printed output of the first request handler (if you have a lot of print statements or something), you can tail:

    $ tail -f /var/log/upstart/api-1.log
    $ tail -f /var/log/upstart/chat-1.log

## Platform

Ubuntu 12.04

