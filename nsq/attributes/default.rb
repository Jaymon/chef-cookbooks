# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "nsq"

default[name] = {}

# I'm really bummed there isn't a latest version tarball to download
default[name]["version"] = "0.2.21"
default[name]["user"] = "nsq"
default[name]["bin_dir"] = ::File.join("", "usr", "local", "bin")
default[name]["share_dir"] = ::File.join("", "usr", "local", "share")
default[name]["data_dir"] = ::File.join("", "var", "nsq")

# p '============================================================================'
# p default[name]
# p '============================================================================'

default[name]['services'] = {
  'nsqlookupd' => {
    'command' => 'nsqlookupd --http-address=0.0.0.0:4161 --tcp-address=0.0.0.0:4160',
    'action' => :start,
  },
  'nsqd' => {
    'command' => "nsqd --lookupd-tcp-address=127.0.0.1:4160 --data-path=#{default[name]["data_dir"]}",
    'action' => :start,
  },
  'nsqadmin' => {
    'command' => "nsqadmin --http-address=0.0.0.0:4171 --lookupd-http-address=127.0.0.1:4161 --template-dir=#{::File.join(default[name]["share_dir"], 'nsqadmin', 'templates')}",
    'action' => :start,
  },
}

