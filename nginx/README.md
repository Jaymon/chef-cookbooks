# Nginx Cookbook

Installs and configures Nginx.


## Versions

Nginx versioning uses an [even/odd mechanic](https://www.nginx.com/blog/nginx-1-16-1-17-released/#NGINX-Versioning-Explained) where the [odd version](https://nginx.org/en/CHANGES) is for active development, and the even version is stable with major bugfixes:

> Mainline is the active development branch where the latest features and bug fixes get added. It is denoted by an odd number in the second part of the version number, for example 1.17.0.
> 
> Stable receives fixes for high‑severity bugs, but is not updated with new features. It is denoted by an even number in the second part of the version number, for example 1.16.0.

This recipe roughly follows [this method of installing Nginx](https://www.linuxbabe.com/ubuntu/install-nginx-latest-version-ubuntu-18-04).


## Configuration block

```ruby
"nginx" => {
   "version" => string,
   "release" => string,
   "config" => {},
   "config_global" => {},
	"servers" => {
	  "localhost" => {
	    "port" => int,
	    "root" => "/path/to/root"
	  },
	},
}
```


## Attributes

------------------------------------------------------------------------------

### version

The Nginx version you want to install, [mainline versions list](https://nginx.org/en/CHANGES)


### release

Defaults to `mainline` but can be changed to `stable`. If you do change to `stable` you'll have to set the version also since the default version is a mainline version.


### config

dict -- this will be merged into the values of each of the configured servers (with the server specific configuration taking precedence).


------------------------------------------------------------------------------

### servers

dict -- the keys are the server names, the value is the configuration for the server

#### port

What port should be listening on

#### root

The root directory to use for static files.

#### host

The web host/domain (eg, example.com).

#### ssl_cert

The ssl certificate to use for the host.

#### ssl_key

The ssl key for the ssl_cert to use for the host.

#### ssl_trusted_cert

The full certificate chain if it isn't already present in the `ssl_cert`.

#### uwsgi_socket

Something like `127.0.0.1:9001`. Set this to activate uwsgi passing on the socket.

#### redirect

a list of servers to 301 redirect to the server `host`.

```
"servers" => {
  "example.com" => {
    "redirect" => ["www.example.com", "www2.example.com"]
  }
}
```


#### headers

A dictionary of `header_name`/`header_value`. Any headers defined here will be sent down on requests, so:

```
"headers" => {
  "X-Frame-Options" => "ALLOW-FROM https://example.com"
}
```

Would result in this being added to the configuration:

```
add_header X-Frame-Options "ALLOW-FROM https://example.com"
```


#### gzip

Set to **true** to enable gzip compression.


#### gzip_types

a list of mimetypes to compress

```
"gzip_types" => [
  "text/plain",
  "text/javascript",
]
```


#### access_log_format

You can set this to a name defined in the `node["conf"]["log_format"]` dict, by default there is a `duration` key that will make the nginx log add the duration to the request also.


#### expires

boolean, set this to **true** or **false** to turn on/off caching for the server.


#### fallback

In the `try_files` of a static site it will check path, then path/ and in the end it will use this, by default this will just return 404 but if you have a static file you would rather server you can put the path (relative to root) here and if it didn't find a real file it would fall back to that path.

The `fallback` value is mutually exclusive with `uwsgi_socket` with `uwsgi_socket` taking precedence (ie, if you define both `fallback` and `uwsgi_socket` in your server dict configuration `fallback` will be ignored).

so basically, by default, a config like this:

```ruby
"servers" => {
    "example.com" => {
        "root" => "/opt/example",
    },
}
```

Would create a `try_files` like:

```
try_files $uri $uri/ =404;
```

But, one like this:

```ruby
"servers" => {
    "example.com" => {
        "root" => "/opt/example",
        "fallback" => "/index.html",
    }
}
```

Would create a `try_files` like:

```
try_files $uri $uri/ /index.html;
```

-------------------------------------------------------------------------------

### config_global

the `config_global` dict holds configuration that is true for every site, it's basically the global configuration for nginx.


#### expires

A dict of content types and their cache values:

```
"expires" => {
  "text/html" => "epoch",
  "application/javascript" => "max",
}
```

Read more about the [possible values](https://www.digitalocean.com/community/tutorials/how-to-implement-browser-caching-with-nginx-s-header-module-on-ubuntu-16-04#step-3-—-configuring-cache-control-and-expires-headers). You can also read about [caching in Nginx in general](https://www.nginx.com/blog/nginx-caching-guide/)


#### types

A dict of content types and their extensions so nginx can serve the correct mime type for things.

```
"types" => {
  "text/foo" => "foo",
  "text/bar" => "bar baz",
}
```

Nginx comes with `/etc/nginx/mime.types` that has the most common extensions and their mime types, this allows you to supplement those with other formats Nginx does not recognize by default yet (like webfonts).


-------------------------------------------------------------------------------

## Using 

Each server name under the `servers` configuration can be started, restarted, and stopped using the Nginx systemd unit:

    $ sudo systemctl start nginx

and to restart it:

    $ sudo systemctl restart nginx

and stop it:

    $ sudo systemctl stop nginx


## Minimum Test

If you want to make sure Nginx is installing correctly, use this config block:

```ruby
"nginx" => {
	"servers" => {
	  "localhost" => {
	    "port" => 9091,
	    "root" => "/opt/nginx/localhost"
	  },
	},
}
```

Then, after the chef run, you can test:

```
$ mkdir -p /opt/nginx/localhost
$ echo "hello world" > /opt/nginx/localhost/index.html
$ curl http://localhost:9091/
hello world
```


## Platform

Ubuntu 18.04.

