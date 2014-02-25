# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "hosts"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "manage hostname"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "hosts", "set the name of the hostname of the machine"

