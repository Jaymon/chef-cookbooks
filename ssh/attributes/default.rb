# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "ssh"

n = {}

n["authorized_keys"] = {}
n["private_keys"] = {}
n["known_hosts"] = {}
n["sshd_config"] = {}
n["sshd_config_file"] = ::File.join("", "etc", "ssh", "sshd_config")

default[name] = n

