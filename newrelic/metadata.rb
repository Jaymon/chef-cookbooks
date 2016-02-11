# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "newrelic"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "newrelic stuff"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"
depends           "pip"

recipe            "server", "add newrelic server monitoring"
recipe            "python", "adds python newrelic-agent support"

