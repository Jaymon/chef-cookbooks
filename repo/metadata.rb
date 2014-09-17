# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "repo"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "manage repos with git"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "pip"

recipe            "repo", "manage configured git repos"
