# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "crontab"

n = {}

n["users"] = {}

n["dirs"] = {
  "log" => ::File.join("", "var", "log", "crontab"),
}

default[name] = n

