# Let's Encrypt

This cookbook was setup using [this guide](https://gist.github.com/cecilemuller/a26737699a7e70a7093d4dc115915de8).

## Configuration

This is how you configure it:

```ruby
"letsencrypt" => {
  "user" => "USERNAME",
  "email" => "NAME@EMAIL.COM",
  "staging" => true, # for testing
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

## Caveats

This will first try and see if the server is up and responding and then use the webroot authentication method, if that fails then it will use the standalone. So that means this should probably be ran before you configure your servers like nginx, because then nginx won't be running and you can use standalone to generate the certificates that nginx can then use in its configuration, if you specify in a server configuration the cert/key you want to use and it doesn't yet exist then you've got a bit of a chicken/egg problem.

## Helpful links

[Certbot installation](https://certbot.eff.org/docs/intro.html#installation)
[Certbot repo](https://github.com/certbot/certbot)

