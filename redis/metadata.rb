# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "redis"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "intall redis"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "redis", "install redis"

