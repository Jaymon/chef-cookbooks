# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "sentinel"

n = {}
n["files"] = []

n["dirs"] = {
  'cache' => ::File.join(::Chef::Config[:file_cache_path], name),
}




default[name] = n

