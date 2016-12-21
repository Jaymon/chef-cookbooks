# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "nodejs"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Installs node.js"
version           "0.1"
long_description  IO.read(::File.join(::File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

recipe            "nodejs", "Install nodejs"

