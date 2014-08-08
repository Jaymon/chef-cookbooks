# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "mongrel2"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "install the mongrel2 http server"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "zeromq"

recipe            "mongrel2", "install mongrel2"
recipe            "mongrel2::python", "install mongrel2 python bindings"
recipe            "mongrel2::src", "if you just need the mongrel source code somewhere"

