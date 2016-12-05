# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "letsencrypt"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Install and configure Let's Encrypt ssl certificates"
version           "0.4"
long_description  IO.read(::File.join(::File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

recipe            "letsencrypt", "Install Let's Encrypt client and prepare environment"
recipe            "letsencrypt::http", "Let's Encrypt ssl certificates generation using http webroot"
recipe            "letsencrypt::standalone", "Let's Encrypt ssl certificates generation using standalone webserver"
recipe            "letsencrypt::snakeoil", "Generate fake certificates so servers can start"

