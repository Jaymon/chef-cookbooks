# Docker Cookbook

Installs Docker.

By default, it just installs the latest version of Docker. It follows [these instructions](https://docs.docker.com/engine/install/ubuntu/).


## Configuration block

Chef's node has a top-level `docker` key so the configuration is done using the `docker-config` key.


```ruby
"docker-config" => {
   "version" => string,
}
```

After running this cookbook you can verify Docker is working by running:

```
$ sudo docker run hello-world
```


## More full-featured Docker cookbooks

* [Docker repo](https://github.com/sous-chefs/docker) ([supermarket](https://supermarket.chef.io/cookbooks/docker))


## TODO

* [Turn on json log rotation?](https://docs.docker.com/config/containers/logging/json-file/)

