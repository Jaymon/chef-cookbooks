# Datetime Cookbook

Setup the date and time on the server


## Attributes

`node["datetime"]["timezone"]` -- the timezone the server should use (default `UTC`)


## Other

If you ever need to set the timezone by hand:

    $ sudo timedatectl set-timezone <TIMEZONE>

Or see what your current timezone setting is:

    $ timedatectl


