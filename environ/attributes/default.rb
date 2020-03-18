# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "environ"

n = {}

# this should hold KEY => VALUE defined environment variables
n[:set] = {}

# holds paths to environment files that will be loaded
n[:file] = []


n["dirs"] = {
  "configuration" => ::File.join("", "etc", name),
  "installation" => ::File.join("", "etc", "profile.d")
}

n["basename"] = "#{name}.sh"

# default[name] = {}
# default[name][:set] = {}
# default[name][:file] = []
# default[name]["global"] = {}
# default[name]["global"][:set] = {}
# default[name]["global"][:file] = []


default[name] = n
