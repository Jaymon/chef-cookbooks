# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "nginx"

default[name] = {}
default[name]["version"] = "1.12.0"
#default[name]["version"] = "1.10.3"
#default[name]["version"] = "1.10.3-1~trusty"
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

default[name]["servers"] = {}
default[name]['available-dir'] = ::File.join("", "etc", name, "sites-available")
default[name]['enabled-dir'] = ::File.join("", "etc", name, "sites-enabled")
default[name]['conf-dir'] = ::File.join("", "etc", name, "conf.d")

