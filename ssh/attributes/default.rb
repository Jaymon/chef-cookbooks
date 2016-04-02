# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "ssh"

default[name] = {}
default[name]["authorized_keys"] = []
default[name]["private_keys"] = []
default[name]["sshd_config"] = {}
default[name]["sshd_config_file"] = ::File.join("", "etc", "ssh", "sshd_config")

