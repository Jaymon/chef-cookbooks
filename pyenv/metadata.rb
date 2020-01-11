# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "pyenv"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "manage different python versions"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

recipe            "pyenv", ""

