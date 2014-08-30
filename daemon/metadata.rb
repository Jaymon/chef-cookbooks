# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "app"
maintainer        "First Opinion"
maintainer_email  "admin@firstopinion.co"
description       "app specific environment configuration"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

depends           "pip"

recipe            "app::user", "do any customizations of the app user"
recipe            "app::services", "set up Upstart services for certain things"

