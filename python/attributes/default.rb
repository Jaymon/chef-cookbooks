# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "python" # https://stackoverflow.com/questions/37891121/chef-reference-to-cookbook-name-in-attributes-default-rb

default[name] = {}

default[name]["common"] = {}
default[name]["environments"] = {}

