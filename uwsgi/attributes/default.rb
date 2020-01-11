# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "uwsgi"

default[name] = {}

default[name]["version"] = "latest"
default[name]["user"] = "www-data"
default[name]["init"] = {}
default[name]["init"]["command"] = "uwsgi"
default[name]["server"] = {}
default[name]["servers"] = {}

default[name]["base_url"] = "https://projects.unbit.it/downloads/"

default[name]["dirs"] = {
  'configuration' => ::File.join("", "etc", name),
  'installation' => ::File.join("", "opt", name),
}
