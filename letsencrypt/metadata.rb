# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "letsencrypt"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Install and configure Let's Encrypt ssl certificates"
version           "0.2"
long_description  IO.read(::File.join(::File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

#depends           "pip"

recipe            "letsencrypt", "Install and configure Let's Encrypt ssl certificates"

