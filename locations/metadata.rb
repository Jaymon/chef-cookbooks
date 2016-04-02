# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "locations"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "put arbitrary files and folders in the right place"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "locations", ""

