# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "package"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "when you need to install a bunch of arbitrary packages"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

recipe            "package", "install packages"
recipe            "package::update", "run apt-get update"
recipe            "package::upgrade", "run apt-get upgrade"
recipe            "package::dist_upgrade", "run apt-get dist-upgrade"

