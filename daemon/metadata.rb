# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "daemon"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "allows you to create systemd managed daemon processes."
version           "0.3"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "18.04"

recipe            "daemon", "Creates your configured daemons"

