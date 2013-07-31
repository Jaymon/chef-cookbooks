# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "scripts"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "run random scripts"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "scripts", "run scripts"

