# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "datetime"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "setup date and time on the server"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "datetime", "setup localtime and timezone information"

