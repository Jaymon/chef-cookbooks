# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "redis"

default[name] = {}

default[name]["version"] = "2.6.16"
default[name]["user"] = "redis"

# I wouldn't mess with these specific values, but that's just me
default[name]["conf"] = {
  'dir' => ::File.join("", "var", "lib", "redis"),
  'dbfilename' => 'redis.db', # this is for compatibility with Chris's ubuntu packages
  'logfile' => ::File.join("", "var", "log", "redis", "redis.log"),
  'daemonize' => 'yes',
  'pidfile' => ::File.join("", "var", "run", "redis", "redis.pid")
}

# these will be added to the dest_conf_file using Redis's include feature
# it is often much better to use this then to completely replace the dest_conf_file
# with your own custom conf_file
default[name]['include_conf_files'] = []

# I wouldn't override these unless you know what you're doing:
default[name]["src_dir"] = ::File.join(::Chef::Config[:file_cache_path], name)
default[name]["src_repo"] = "https://github.com/antirez/redis.git"


