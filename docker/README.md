# Docker Cookbook

Installs Docker.

By default, it just installs the latest version of Docker. It follows [these instructions](https://docs.docker.com/engine/install/ubuntu/).

After running this cookbook you can verify Docker is working by running:

```
$ sudo docker run hello-world
```


## Configuration

Chef's node has a top-level `docker` key so the configuration is done using the `docker-config` key.


```ruby
"docker-config" => {
  "version" => string,
  "users" => list[string]
}
```


### Attributes

* `version` -- string, the Docker version to install, defaults to the latest version.
* `users` -- list[string], the users who will join the `docker` group. This should allow the users to run docker commands without `sudo`.


## More full-featured Docker cookbooks

* [Docker repo](https://github.com/sous-chefs/docker) ([supermarket](https://supermarket.chef.io/cookbooks/docker))
