# Nginx Cookbook

Installs Nginx


## Attributes

### defaults

dict -- this will be merged into the values of each of the configured servers (with the server specific configuration taking precedence).


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


## Using 

Each server name under the `servers` configuration can be started and stopped using init:

    $ sudo /etc/init.d/nginx restart

and stop it:

    $ sudo /etc/init.d/nginx stop

and you can manage all installed uWSGI servers using `uwsgi`:

    $ sudo /etc/init.d/nginx start


## Platform

Ubuntu 14.04 is what we run.

