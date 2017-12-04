# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "selenium"

default[name] = {}

# versions come from: http://www.seleniumhq.org/download/
default[name]["server_version"] = "3.7.1"
default[name]["python_version"] = "3.7.0"
#default[name]["gecko_version"] = "0.19.1" # firefox

