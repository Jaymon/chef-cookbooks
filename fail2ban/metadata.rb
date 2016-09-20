# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "fail2ban"
maintainer        "Topher"
maintainer_email  "topher@firstopinionapp.com"
description       "Installs and configures fail2ban"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"
recipe            "fail2ban", "install fail2ban"
