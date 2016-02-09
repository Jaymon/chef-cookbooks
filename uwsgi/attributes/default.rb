# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "uwsgi"

default[name] = {}

default[name]["version"] = "2.0.11.1"
default[name]["user"] = "www-data"
default[name]["init"] = {}
default[name]["init"]["command"] = "uwsgi"
default[name]["server"] = {}

