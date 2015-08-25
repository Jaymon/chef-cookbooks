# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "motd"

default[name] = {}
default[name]["message"] = "" # must be a format string with #{param_key} syntax
default[name]["params"] = {} # keys must be symbols

