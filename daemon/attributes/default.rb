# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "app"

default[name] = {}

default[name]['api'] = {}
default[name]['api']["command"] = ""
default[name]['api']["count"] = 1

default[name]['chat'] = {}
default[name]['chat']["command"] = ""
default[name]['chat']["count"] = 1

default[name]['admin'] = {}
default[name]['admin']["command"] = ""
default[name]['admin']["count"] = 1
default[name]['admin']["static_dir"] = ""

default[name]['ops'] = {}
# ops doesn't need repo because we have to have ops on the box to run chef, chicken, meet egg

default[name]['common'] = {}

default[name]['user'] = {}
default[name]['user']["username"] = ""
