# Let's Encrypt

This cookbook was setup using [this guide](https://gist.github.com/cecilemuller/a26737699a7e70a7093d4dc115915de8).


## Configuration

This is how you configure it:

```ruby
"letsencrypt" => {
  "user" => "USERNAME",
  "email" => "NAME@EMAIL.COM",
  "staging" => true, # for testing
  "plugin" => "http", # available: http, standalone
  "servers" => {
    "server.com" => {
      "root" => "/path/to/base/directory/of/server",
    },
    "server2.com" => {
      "root" => "/path/to/base/directory/of/server2",
      "domains" => ["www.server2.com", "foo.server2.com"] # cert can handle multiple subdomains
    },
  },
},
```

A more complete example with more stuff fleshed out options:

```ruby
attrs["letsencrypt"] = {
  "user" => "USERNAME",
  "email" => "NAME@EMAIL.COM",
  "plugin" => "http",
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
  "servers" => {
    "server.com" => {
      "root" => "/path/to/base/directory/of/server",
      "staging" => true,
      "root" => attrs.in_web("le1"),
      "notifies" => [
        [:reload, "service[NAME]", :delayed],
      ],
    },
    "server2.com" => {
      "root" => "/path/to/base/directory/of/server2",
      "domains" => ["www.server2.com", "foo.server2.com"] # cert can handle multiple subdomains
    },
  },
}
```

It's advisable to not mix and match your plugins for the box, because the renew command isn't good when the some domains use **standalone** while others user **http**.


## The HTTP recipe

Create certificates through **webroot** validation using the `letsencrypt::http` recipe. How this works is you need to use the `letsencrypt::snakeoil` recipe before your webserver recipe, and then after your webserver recipe you would run the `letsencrypt::http` recipe, the order here is important

```ruby
base_run_list = [
  "recipe[letsencrypt::snakeoil]",
  "recipe[nginx]",
  "recipe[letsencrypt::http]",
]
```

The reason why we do this is because we have a bit of a chicken/egg problem here, in order for the webserver (like nginx) to start, we need certificates, but in order to use Let's Encrypt's webroot, the webserver needs to be up and answering requests on port 80, so the snakeoil recipe will create fake certs and place them in the correct location to allow the webserver to start, and then the http recipe will go in and create real certificates, and the `notifies` list in the configuration block for the domain will be able to restart/reload your webserver service on successful Let's Encrypt SSL certificate creation.

So, once again, the steps to make `letsencrypt::http` work:

* Run `letsencrypt::snakeoil` before your webserver recipe
* Run your webserver recipe, your webserver must answer requests on port 80, even if it is just forwarding those to port 443.
* Run `letsencrypt::http` after you run your webserver recipe, this will add actual legit SSL certs
* In your `letsencrypt` configuration server block, add a `notifies` value that will tell your webserver to reload/restart on successful SSL certificate creation.

Yes, you are right, Let's Encrypt sucks for automation.


## The Standalone recipe

Create certificates through **standalone** validation using the `letsencrypt::standalone` recipe. This means Let's Encrypt will start a standalone web server on port 80 to do its domain validation, that means you can't have anything else running on port 80.

You will want to add the **standalone** recipe before you install your webserver:

```ruby
base_run_list = [
  "recipe[letsencrypt::standalone]",
  "recipe[nginx]",
]
```

And you will want your `post-hook` and `pre-hook` configuration blocks to stop the server (in the `pre-hook`) and to start the server (in the `post-hook`) so when Let's Encrypt renews the certificate it can use port 80 again. You obviously don't need to do that if your webserver doesn't use port 80, but you would want to reload or restart the server on a successful renew so the server can pick up the new certs.


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

