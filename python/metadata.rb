# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "python"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "just a way to test some things real quick"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

depends           "pyenv"

recipe            "python", "Installs python and manages python virtual environments and dependencies"


