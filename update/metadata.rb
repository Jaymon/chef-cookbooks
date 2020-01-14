# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "update"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Update certain packages and things, fixes for vulnerabilities like heartbleed and shellshocker"
version           "0.2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

depends           "package"

recipe            "update", "updates everything"
recipe            "update::bash", "updates bash"
recipe            "update::openssl", "updates openssl"
recipe            "update::linux", "updates the linux kernel"

