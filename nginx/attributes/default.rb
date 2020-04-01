# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "nginx"

n = {}

n["version"] = "1.17.9"

n["release"] = "mainline"
n["release_bases"] = {
  "stable" => "https://nginx.org/packages", # stable
  "mainline" => "http://nginx.org/packages/mainline", # mainline
}

n['dirs'] = {
  'available' => ::File.join("", "etc", name, "sites-available"),
  'enabled' => ::File.join("", "etc", name, "sites-enabled"),
  'conf.d' => ::File.join("", "etc", name, "conf.d"),
  'log' => ::File.join("", "var", "log", name)
}


###############################################################################
# default config dict
#
# the config dict will be merged with each server dict and allows you to set
# global defaults that each individual server's dict will inherit
###############################################################################
n["config"] = {}
n["config"]["gzip"] = false
n["config"]["gzip_types"] = [
  "text/plain",
  "text/css",
  "application/json",
  "application/x-javascript",
  "application/javascript",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript",
]

# in the try_files of a static site it will check path, then path/ and in the end
# it will use this, by default this will just return 404 but if you have a static
# file you would rather server you can put the path (relative to root) here and if
# it didn't find a real file it would fall back to that path
n["config"]["fallback"] = "=404"


###############################################################################
# conf dict
#
# the conf dict holds configuration that is true for every site, it's basically
# the global configuration for nginx
###############################################################################
n["config_global"] = {}
# this will set caching headers for these mimetypes
n["config_global"]["expires"] = {
  "default" => "off",
  "text/html" => "epoch",
  "text/css" => "max",
  "application/javascript" => "max",
  "~image/" => "max",
}

# any additional mime types you want nginx to recognize
n["config_global"]["types"] = {
  "application/x-font-ttf" => "ttc ttf",
  "application/x-font-otf" => "otf",
  #"application/font-woff2" => "woff2", # was getting this error: nginx: [warn] duplicate
  # extension "woff2", content type: "application/font-woff2", previous content type:
  # "font/woff2" in /etc/nginx/conf.d/conf.conf:22
}

#n["config_global"]["access_log_format"] = "duration"
n["config_global"]["log_format"] = {
  "duration" => [
    '$remote_addr - $remote_user [$time_local]',
    '"$request" $status $body_bytes_sent',
    '"$http_referer" "$http_user_agent"',
    '$request_time',
  ].join(" ")
}

###############################################################################
# servers dict
#
# each key is the name of the server (eg, example.com) and the value is a dict that
# contains configuration for that server
###############################################################################
n["servers"] = {}


default[name] = n

