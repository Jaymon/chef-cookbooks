# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "python"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "just a way to test some things real quick"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

depends           "pip"
depends           "pyenv"

recipe            "python", ""
#recipe            "python::package/redis", ""
#recipe            "postgres::python", "Installs Postgres psycopg python bindings"
#recipe            "selenium:python", "Install Selenium python bindings"


