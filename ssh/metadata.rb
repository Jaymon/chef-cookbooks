# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "ssh"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "provide some ssh fu"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "ssh::authorized_keys", "add keys from a list of files into ~/.ssh/authorized_keys"

