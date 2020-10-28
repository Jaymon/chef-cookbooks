# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "sentinel"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Allows performing an action when something changes on the system"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "18.04"

recipe            "sentinel", "Run through configuration and run commands"

