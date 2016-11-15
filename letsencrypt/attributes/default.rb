# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "letsencrypt"

default[name] = {}

binroot = ::File.join("", "opt", "letsencrypt")
default[name]["binroot"] = binroot
default[name]["bincmd"] = ::File.join(binroot, "certbot-auto")

root = ::File.join("", "etc", "letsencrypt")
default[name]["root"] = root
default[name]["certroot"] = ::File.join(root, "live")
default[name]["renewroot"] = ::File.join(root, "renewal")
default[name]["archiveroot"] = ::File.join(root, "archive")
default[name]["snakeoilroot"] = ::File.join(root, "snakeoil")

default[name]["staging"] = false
default[name]["servers"] = {}

