# https://docs.chef.io/config_rb_metadata/
name              "docker"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Installs Docker"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "20.04"

recipe            "docker", ""

