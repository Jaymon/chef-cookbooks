# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "fail2ban"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Installs and configures fail2ban"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "18.04"
recipe            "fail2ban", "install and configure fail2ban"

