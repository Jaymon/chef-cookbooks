# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "nginx"

n = {}

n["version"] = "1.17.9"

n['dirs'] = {
  'available' => ::File.join("", "etc", name, "sites-available"),
  'enabled' => ::File.join("", "etc", name, "sites-enabled"),
  'conf.d' => ::File.join("", "etc", name, "conf.d"),
  'log' => ::File.join("", "var", "log", name)
}


###############################################################################
# defaults dict
#
# the defaults dict will be merged with each server dict and allows you to set
# global defaults that each individual servers dict will inherit
###############################################################################
n["config_default"] = {}
n["config_default"]["gzip"] = false
n["config_default"]["gzip_types"] = [
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
n["config_default"]["fallback"] = "=404"


###############################################################################
# conf dict
#
# the conf dict holds configuration that is true for every site, it's basically
# the global configuration for nginx
###############################################################################
n["config"] = {}
# this will set caching headers for these mimetypes
n["config"]["expires"] = {
  "default" => "off",
  "text/html" => "epoch",
  "text/css" => "max",
  "application/javascript" => "max",
  "~image/" => "max",
}

# any additional mime types you want nginx to recognize
n["config"]["types"] = {
  "application/x-font-ttf" => "ttc ttf",
  "application/x-font-otf" => "otf",
  #"application/font-woff2" => "woff2", # was getting this error: nginx: [warn] duplicate
  # extension "woff2", content type: "application/font-woff2", previous content type:
  # "font/woff2" in /etc/nginx/conf.d/conf.conf:22
}

#default[name]["defaults"]["access_log_format"] = "duration"

n["config"]["log_format"] = {
  # the duration log format will allow 
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

