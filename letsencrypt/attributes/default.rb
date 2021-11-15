# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "letsencrypt"

default[name] = {}

binroot = ::File.join("", "opt", "letsencrypt")
default[name]["binroot"] = binroot
default[name]["bincmd"] = "/snap/bin/certbot"

root = ::File.join("", "etc", "letsencrypt")
default[name]["root"] = root
default[name]["certroot"] = ::File.join(root, "live")
default[name]["renewroot"] = ::File.join(root, "renewal")
default[name]["archiveroot"] = ::File.join(root, "archive")
default[name]["snakeoilroot"] = ::File.join(root, "snakeoil")

default[name]["pre-hook"] = []
default[name]["post-hook"] = []
default[name]["renew-hook"] = []
default[name]["pre-hook_path"] = ::File.join(binroot, "pre-hook.sh")
default[name]["post-hook_path"] = ::File.join(binroot, "post-hook.sh")
default[name]["renew-hook_path"] = ::File.join(binroot, "renew-hook.sh")


default[name]["staging"] = false
default[name]["servers"] = {}

