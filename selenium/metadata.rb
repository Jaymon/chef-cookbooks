# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "selenium"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "Everything needed for a headless browser setup"
version           "0.1"
long_description  IO.read(::File.join(::File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

#depends           "pip"

recipe            "selenium", "Install basic Selenium server"
recipe            "selenium:chrome", "Install selenium chromedriver"
recipe            "selenium:xvfb", "Install the virtual X11 manager thingy"

