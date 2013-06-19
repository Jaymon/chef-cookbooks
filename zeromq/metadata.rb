# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "zeromq"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "install ZeroMQ from source"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "pip"

recipe            "zeromq", "install zeromq"
recipe            "zeromq::python", "install python bindings pyzmq"

