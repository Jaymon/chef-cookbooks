# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "pip"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "install pip and python pip packages"
version           "0.2"
long_description  IO.read(::File.join(::File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "pip", "install python pip, and install python packages with pip"

