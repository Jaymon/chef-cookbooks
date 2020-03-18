# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "uwsgi"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "install the uwsgi server"
version           "0.4"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "18.04"

recipe            "uwsgi", "install uwsgi"

