# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "letsencrypt"

default[name] = {}

default[name]["binroot"] = ::File.join("", "opt", "letsencrypt")
default[name]["certroot"] = ::File.join("", "etc", "letsencrypt", "live")
default[name]["webroot"] = ::File.join(".well-known", "acme-challenge")
default[name]["staging"] = false
default[name]["servers"] = {}

