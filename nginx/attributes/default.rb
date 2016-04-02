# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "nginx"

default[name] = {}
default[name]["static-servers"] = {}
default[name]["uwsgi-servers"] = {}
default[name]['available-dir'] = ::File.join("", "etc", name, "sites-available")
default[name]['enabled-dir'] = ::File.join("", "etc", name, "sites-enabled")

