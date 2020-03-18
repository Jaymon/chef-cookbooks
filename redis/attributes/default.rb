# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "redis"

n = {}

n["version"] = "5.0.8"
n["user"] = "redis"

n['command'] = ::File.join("", "usr", "local", "bin", "redis-server")
n['command_shutdown'] = ::File.join("", "usr", "local", "bin", "redis-cli")

n["dirs"] = {
  'etc' => ::File.join("", "etc", "redis"),
  'log' =>  ::File.join("", "var", "log", "redis"),
  'lib' => ::File.join("", "var", "lib", "redis"),
  'conf.d' =>  ::File.join("", "etc", "redis", "conf.d"),
  'src' => ::File.join(::Chef::Config[:file_cache_path], name),
  "service" => ::File.join("", "etc", "systemd", "system"),
}

# I wouldn't mess with these specific values, but that's just me
n["config_default"] = {
  'dir' => ::File.join("", "var", "lib", "redis"),
  'dbfilename' => 'redis.db',
  'logfile' => ::File.join("", "var", "log", "redis", "redis.log"),
  # this is needed for systemd https://gist.github.com/hackedunit/a53f0b5376b3772d278078f686b04d38#gistcomment-2816179
  "supervised" => "systemd",
}

# these will be added to the dest_conf_file using Redis's include feature
# it is often much better to use this then to completely replace the dest_conf_file
# with your own custom conf_file
n['config_files'] = []

# most configuration will go here as key => val
n['config'] = {}

# I wouldn't override these unless you know what you're doing:
n["src_repo"] = "https://github.com/antirez/redis.git"

default[name] = n

