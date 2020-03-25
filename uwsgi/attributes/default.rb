# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "uwsgi"

n = {
  "version" => "latest",
  "base_url" => "https://projects.unbit.it/downloads/",
  "user" => "www-data",
}

# contains directories, files, or "KEY=VALUE" strings
n["environ"] = []

# the binary that will be ran to start uwsgi
n["command"] = ::File.join("", "usr", "local", "bin", "uwsgi")

# directory configuration
n["dirs"] = {
  "configuration" => ::File.join("", "etc", name),
  "installation" => ::File.join("", "opt", name),
  "service" => ::File.join("", "etc", "systemd", "system")
}

# configuration for each uwsgi server will go in here, with the server name as the key
n["servers"] = {}

# global configuration for each server in servers can go in here, this is meant to 
# be defined by the user which is why it is separate from server_default
n["config"] = {}

# this contains default configuration that can be overridden in both server and 
# the server specific configuration, it's based on:
# https://www.techatbloomberg.com/blog/configuring-uwsgi-production-deployment/
n["config_default"] = {
  "strict" => true,
  "master" => true,
  "no-orphans" => true,
  "enable-threads" => true,
  "vacuum" => true, # Delete sockets during shutdown
  "single-interpreter" => true,
  "need-app" => true,
  "memory-report" => true,
  "disable-logging" => true, # I'm not sure about keeping this one true
  "log-4xx" => true,
  "log-5xx" => true,
  "auto-procname" => true,
  "show-config" => true,
  "plugins-list" => true,
}

# on 3-25-2020 I removed die-on-term from config_default because it seems like it
# was a legacy thing needed for upstart:
# https://uwsgi-docs.readthedocs.io/en/latest/Upstart.html#what-is-die-on-term
# but not systemd
# "die-on-term" => true, # Shutdown when receiving SIGTERM (default is respawn)

default[name] = n

