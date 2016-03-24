# Nginx Cookbook

Installs Nginx


## Attributes

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

#### uwsgi_socket

Something like `127.0.0.1:9001`. Set this to activate uwsgi passing on the socket.


## Using 

Each server name under the `servers` configuration can be started and stopped using init:

    $ sudo /etc/init.d/nginx restart

and stop it:

    $ sudo /etc/init.d/nginx stop

and you can manage all installed uWSGI servers using `uwsgi`:

    $ sudo /etc/init.d/nginx start


## Platform

Ubuntu 14.04 is what we run.

