# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "nginx"

default[name] = {}
default[name]["version"] = "1.12.1"
#default[name]["version"] = "1.10.3"
#default[name]["version"] = "1.10.3-1~trusty"
default[name]['available-dir'] = ::File.join("", "etc", name, "sites-available")
default[name]['enabled-dir'] = ::File.join("", "etc", name, "sites-enabled")
default[name]['conf-dir'] = ::File.join("", "etc", name, "conf.d")

###############################################################################
# defaults dict
#
# the defaults dict will be merged with each server dict and allows you to set
# global defaults that each individual servers dict will inherit
###############################################################################
default[name]["defaults"] = {}
default[name]["defaults"]["gzip"] = false
default[name]["defaults"]["gzip_types"] = [
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
default[name]["defaults"]["fallback"] = "=404"


###############################################################################
# conf dict
#
# the conf dict holds configuration that is true for every site, it's basically
# the global configuration for nginx
###############################################################################
default[name]["conf"] = {}
# this will set caching headers for these mimetypes
default[name]["conf"]["expires"] = {
  "default" => "off",
  "text/html" => "epoch",
  "text/css" => "max",
  "application/javascript" => "max",
  "~image/" => "max",
}

# any additional mime types you want nginx to recognize
default[name]["conf"]["types"] = {
  "application/x-font-ttf" => "ttc ttf",
  "application/x-font-otf" => "otf",
  "application/font-woff2" => "woff2",
}

#default[name]["defaults"]["access_log_format"] = "duration"

default[name]["conf"]["log_format"] = {
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
default[name]["servers"] = {}

