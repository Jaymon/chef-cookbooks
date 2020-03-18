# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "environ"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "manipulate environment variables, like a boss"
version           "0.3"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "18.04"

recipe            "environ", "do stuff with environment variables"

