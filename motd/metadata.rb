# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "motd"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "format the message of the day for when you ssh into the box"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

recipe            "motd", ""

