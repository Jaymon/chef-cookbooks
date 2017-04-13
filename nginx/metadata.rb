# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "nginx"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Configures and installs Nginx"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"
recipe            "nginx", "install nginx"

