# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "redis"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "intall redis"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "pip"

recipe            "redis", "install redis"
recipe            "redis::python", "install python bindings redis-py"
recipe            "redis::pgbouncer", "install pgbouncer"
