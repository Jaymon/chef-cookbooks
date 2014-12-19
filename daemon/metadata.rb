# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "daemon"
maintainer        "First Opinion"
maintainer_email  "admin@firstopinion.co"
description       "allows you to create upstart managed daemon processes."
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "12.04"

recipe            "daemon", ""

