# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "diff"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "apply arbitrary diff patches against files"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "diff", "apply diff"

