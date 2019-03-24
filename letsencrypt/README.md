# Let's Encrypt

This cookbook was setup using [this guide](https://gist.github.com/cecilemuller/a26737699a7e70a7093d4dc115915de8).


## Configuration


### keys

Here are some of the different keys you can set in the configuration hash


-------------------------------------------------------------------------------

#### email

**required**

The email address that Let's Encrypt will use to create the certificates.


-------------------------------------------------------------------------------

#### plugin

**required**

possible values: _http_ or _standalone_

* _http_ - Configures the `letsencrypt::http` recipe and uses the [webroot validation method](https://certbot.eff.org/docs/using.html#webroot) on a currently running webserver to create and renew certificates

* _standalone_ - Configures the `letsencrypt::standalone` recipe and uses the [standalone validation method](https://certbot.eff.org/docs/using.html#standalone) on port 80 to create and renew the certificates. This means port 80 has to be available when the certificates are generated or renewed.

Look at the sections for each of these recipes below to learn how to configure them.


-------------------------------------------------------------------------------

#### domains

**required**

A hash of domains containing domain (eg, _example.com_ ) specific configuration for each domain key in the `domains` hash. So the key is the domain you are configuring Let's Encrypt for, and the value is a hash of configuration that is specific for that domain.

Domain blocks can be configured to [notify](https://docs.chef.io/resource_common.html#notifications) services:

```ruby
"domains" => {
  "example.com" => {
    "notifies" => [
      [:reload, "service[NAME]", :delayed],
    ],
  },
},
```


-------------------------------------------------------------------------------

#### renew-hook

A list of commands that should be run on domain after a successful certificate renewal

```
$ ./certbot-auto --help renew
  --renew-hook RENEW_HOOK
                    Command to be run in a shell once for each
                    successfully renewed certificate. For this command,
                    the shell variable $RENEWED_LINEAGE will point to the
                    config live subdirectory containing the new certs and
                    keys; the shell variable $RENEWED_DOMAINS will contain
                    a space-delimited list of renewed cert domains
                    (default: None)
```

These commands will be placed in a file that will be hooked up to the renew cronjob.


-------------------------------------------------------------------------------

#### pre-hook

A list of commands that should be run before a domain certificate renewal

```
$ ./certbot-auto --help renew
  --pre-hook PRE_HOOK   Command to be run in a shell before obtaining any
                        certificates. Intended primarily for renewal, where it
                        can be used to temporarily shut down a webserver that
                        might conflict with the standalone plugin. This will
                        only be called if a certificate is actually to be
                        obtained/renewed. (default: None)
```


-------------------------------------------------------------------------------

#### post-hook

A list of commands that should be run after a domain certificate renewal

```
$ ./certbot-auto --help renew
  --post-hook POST_HOOK
                        Command to be run in a shell after attempting to
                        obtain/renew certificates. Can be used to deploy
                        renewed certificates, or to restart any servers that
                        were stopped by --pre-hook. This is only run if an
                        attempt was made to obtain/renew a certificate.
                        (default: None)
```


-------------------------------------------------------------------------------

#### user

For _http_ plugin generated SSL certificates, a directory needs to be created that can be read by the running webserver, those directories will be owned by this username. That means this is **not** needed if you use `letsencrypt::standalone` recipe.


-------------------------------------------------------------------------------

#### staging

Mainly for testing, set to **true** if you want Let's Encrypt to generate non-valid certificates. These certificates are not subject to usage restrictions and domain throttling, so you can request them again and again without being throttled.


### Example hashes

This is an example with all the configuration parameters:

```ruby
attrs["letsencrypt"] = {
  "user" => "USERNAME",
  "email" => "NAME@EMAIL.COM",
  "plugin" => "http", # or "standalone"
  "staging" => true, # for testing
  "renew-hook" => [
    "/etc/init.d/nginx reload",
  ],
  "pre-hook" => [
    "/etc/init.d/nginx stop",
    "stop SOMETHING_ELSE",
  ],
  "post-hook" => [
    "/etc/init.d/nginx start",
    "start SOMETHING_ELSE",
  ],
  "domains" => {
    "example.com" => {
      "root" => "/path/to/base/directory/of/domain",
      "staging" => true,
      "notifies" => [
        [:reload, "service[NAME]", :delayed],
      ],
    },
    "example2.com" => {
      "root" => "/path/to/base/directory/of/domain2",
      "domains" => ["www.example2.com", "foo.example2.com"] # cert can handle multiple subdomains
    },
  },
}
```

It's advisable to not mix and match your plugins for the box, because the Let's encrypt renew command (that this cookbook sets up in a cron job) isn't good when some domains use **standalone** while others user **http**.


## The HTTP recipe

-----

**NOTE** - This recipe has serious problems working with our _nginx_ recipe, what happens is the _nginx_ recipe doesn't start any new servers until the end of the run, so what that means is on first run through this recipe won't be able to access anything because the server isn't actually started, but this recipe also cleans up the snakeoil stuff, so it leaves the server in a bad state where it can't start the server but also can't get the Let's Encrypt certificates. Now, what might work is making sure the server is started before running this, similar to how we do do standalone:

```ruby
"renew-hook" => [
  "reload SERVICE",
],
"domains" => {
  "example.com" => {
    "plugin" => "http",
    "root" => "/webroot/path",
    "notifies" => [
      [:start, "service[NAME]", :before],
      [:reload, "service[NAME]", :delayed],
    ],
  },
},
```

This might work, but I will need to clean room test it, in the meantime we're just going to use _standalone_ exclusively.

Another way to go about it is to just use standalone to get the certs if the server is not answering requests on port 80 and then change the config to use `webroot` renewal.

-----

Create certificates through **webroot** validation using the `letsencrypt::http` recipe. How this works is you need to use the `letsencrypt::snakeoil` recipe before your webserver recipe, and then after your webserver recipe you would run the `letsencrypt::http` recipe, the order here is important

```ruby
base_run_list = [
  "recipe[letsencrypt::snakeoil]",
  "recipe[nginx]",
  "recipe[letsencrypt::http]",
]
```

The reason why we do this is because we have a bit of a chicken/egg problem here, in order for the webserver (like nginx) to start, we need certificates to exist, but in order to use Let's Encrypt's webroot, the webserver needs to be up and answering requests on port 80, so the snakeoil recipe will create fake certifcates and place them in the correct location to allow the webserver to start, and then the http recipe will go in and replace the fake certificates with real certificates, and the `notifies` list in the configuration block for the domain will be able to restart/reload the webserver service on a successful Let's Encrypt SSL certificate creation.

So, once again, the steps to make `letsencrypt::http` work:

* Run `letsencrypt::snakeoil` before any webserver related recipes
* Run webserver setup recipes, the webserver must answer requests on port 80, even if it is just forwarding those to port 443.
* Run `letsencrypt::http` after running the webserver setup recipes, this will add the actual valid Let's Encrypt SSL certs
* In the `letsencrypt` configuration domain block, add a `notifies` value that will tell the webserver to reload/restart on successful SSL certificate creation, causing the webserver to pick up the new valid Let's Encrypt SSL certificates.

Yes, you are right, Let's Encrypt sucks for automation.

Because the webserver shouldn't be stopped while using the `letsencrypt::http` recipe, the domain configuration should be setup to reload the server on successful certificate generation and renewal so the new certificates can be picked up.

```ruby
"renew-hook" => [
  "reload SERVICE",
],
"domains" => {
  "example.com" => {
    "plugin" => "http",
    "root" => "/webroot/path",
    "notifies" => [
      [:reload, "service[NAME]", :delayed],
    ],
  },
},
```


## The Standalone recipe

Create certificates through **standalone** validation using the `letsencrypt::standalone` recipe. This means Let's Encrypt will start a standalone webserver on port 80 to do its domain validation, that means nothing else can be running on port 80.

You will want to add the **standalone** recipe before you install your webserver:

```ruby
base_run_list = [
  "recipe[letsencrypt::standalone]",
  "recipe[nginx]",
]
```

And you will want your `post-hook` and `pre-hook` configuration blocks to stop the webserver (in the `pre-hook`) and to start the webserver (in the `post-hook`) so when Let's Encrypt renews the certificate it can use port 80 again. You obviously don't need to do that if your webserver doesn't use port 80, but you would want to reload or restart the webserver on a successful renew so the webserver can pick up the new certs.

Also, to make sure there aren't any problems while running Chef you will probably want to configure your domain block to stop and start the webserver if needed:

```ruby
"pre-hook" => [
  "stop SERVICE_ON_PORT_80",
],
"post-hook" => [
  "start SERVICE_ON_PORT_80",
],
"domains" => {
  "example.com" => {
    "plugin" => "standalone",
    "notifies" => [
      [:stop, "service[NAME]", :before],
      [:reload, "service[NAME]", :delayed],
    ],
  },
},
```


## Caveats and Known problems

### Let's Encrypt uses port 80

You cannot change this, it is what it is:

* https://community.letsencrypt.org/t/generate-certificate-8443-instead-of-443/19623/8
* https://community.letsencrypt.org/t/support-for-ports-other-than-80-and-443/3419/77
* https://community.letsencrypt.org/t/domain-validation-on-80-and-443-but-no-override/21598/11
* https://community.letsencrypt.org/t/how-to-specify-a-port-different-from-443-for-the-dvsni-challenge/12753/2
* https://github.com/certbot/certbot/issues/2801
* https://github.com/letsencrypt/acme-spec/issues/33


### Route 53

If you have multiple boxes that are behind Route53, then this fails because it will only put the certificates on one box and not on the others, and even if we figured out a good way to distribute the certs you still have to deal with renewing them. It might work just fine with a different certificate on each server, we would need further testing.


### Other

On vanilla servers, we may need to [Force dependencies](https://github.com/certbot/certbot/issues/1706#issuecomment-197380593)


## Helpful links

* [ACME (Automatic Certificate Management Environment) Spec](https://ietf-wg-acme.github.io/acme/)
* [Certbot installation](https://certbot.eff.org/docs/intro.html#installation)
* [Let's Encrypt Docs](https://letsencrypt.org/docs/)
* [Certbot repo](https://github.com/certbot/certbot)
* [This issue helped sort through stuff](https://github.com/certbot/certbot/issues/1706)
* [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-14-04)
* [DNS Domain validation](https://github.com/lukas2511/dehydrated/wiki/Examples-for-DNS-01-hooks)
* [Let's Encrypt Community Q&A site](https://community.letsencrypt.org/)
* [Mixing standalon and webroot](https://github.com/certbot/certbot/issues/2364)


## Troubleshooting

If you ever get a `_remove_dead_weakref` error:

```
Error: couldn’t get currently installed version for /opt/eff.org/certbot/venv/bin/letsencrypt:
Traceback (most recent call last):
File “/opt/eff.org/certbot/venv/bin/letsencrypt”, line 7, in 
from certbot.main import main
File “/opt/eff.org/certbot/venv/local/lib/python2.7/site-packages/certbot/main.py”, line 4, in 
import logging.handlers
File “/usr/lib/python2.7/logging/init.py”, line 26, in 
import sys, os, time, cStringIO, traceback, warnings, weakref, collections
File “/usr/lib/python2.7/weakref.py”, line 14, in 
from _weakref import (
ImportError: cannot import name _remove_dead_weakref
```

And this works in your environment (run from the command line):

```
$ python2 -c 'import weakref'
```

The virtual environment certbot uses has gotten out of sync, this can happen if you use the `update::python2` recipe. The fix is to just remove the `eff.org` environment:

```
$ rm -rf /opt/eff.org
```

via [Cannot renew certificate “ImportError: cannot import name \_remove\_dead\_weakref”](https://community.letsencrypt.org/t/cannot-renew-certificate-importerror-cannot-import-name-remove-dead-weakref/58148)