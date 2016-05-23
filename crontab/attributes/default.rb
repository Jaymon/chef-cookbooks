# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "daemon"

default[name] = {}
default[name]["logdir"] = ::File.join("", "var", "log", "cron"),

