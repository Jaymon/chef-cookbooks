# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "sentry"

default[name] = {}

# I'm really bummed there isn't a latest version tarball to download
default[name]["db"] = "postgres"
default[name]["user"] = "www-data"

