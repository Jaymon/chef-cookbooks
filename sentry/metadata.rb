# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "nsq"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "install and configure nsq for message passing goodness"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "pip"

recipe            "sentry", "install sentry server"
recipe            "sentry::python", "install raven python sentry bindings"

