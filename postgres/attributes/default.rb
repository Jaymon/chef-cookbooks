# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "postgres"

# the user hash is in username => password format
default[name]["users"] = {"postgres" => "postgres"}

# the databases hash is in username => [dbname1, ...] format
default[name]["databases"] = {}

version_str = %x(apt-cache show postgresql|grep Version)
m = version_str.match(/^Version:\s*([\d\.]+)/i)
version = m[1]
default[name]["version"] = version
default[name]["conf_file"] = ::File.join("", "etc", "postgresql", version, "main", "postgresql.conf")

default[name]["conf"] = {}
default[name]["conf"]["listen_addresses"] = "'*'"

