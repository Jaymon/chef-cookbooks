# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "sentry"

default[name] = {}

# I'm really bummed there isn't a latest version tarball to download
default[name]["db"] = "postgres"
default[name]["user"] = "www-data"

# default[name]['services'] = {
#   'nsqlookupd' => {
#     'command' => 'nsqlookupd --http-address=0.0.0.0:4161 --tcp-address=0.0.0.0:4160',
#     'action' => :start,
#   },
#   'nsqd' => {
#     'command' => "nsqd --lookupd-tcp-address=127.0.0.1:4160 --data-path=#{default[name]["data_dir"]}",
#     'action' => :start,
#   },
#   'nsqadmin' => {
#     'command' => "nsqadmin --http-address=0.0.0.0:4171 --lookupd-http-address=127.0.0.1:4161 --template-dir=#{::File.join(default[name]["share_dir"], 'nsqadmin', 'templates')}",
#     'action' => :start,
#   },
# }
# 
