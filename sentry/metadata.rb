# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "sentry"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "install sentry"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "pip"

recipe            "sentry", "install sentry server"

