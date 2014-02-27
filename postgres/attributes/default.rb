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
default[name]["hba_file"] = ::File.join("", "etc", "postgresql", version, "main", "pg_hba.conf")

default[name]["conf"] = {}
default[name]["conf"]["listen_addresses"] = "'*'"

default[name]["hba"] = [
  { # this makes postgres operate easier in the environment we've set up (.pgpass files work as expected)
    'connection' => 'local',
    'database' => 'all',
    'user' => 'all',
    'method' => 'md5',
  },
  { # this makes it possible for postgres to connect to remote hosts
    'connection' => 'host',
    'database' => 'all',
    'user' => 'all',
    'address' => '0.0.0.0/0',
    'method' => 'md5',
  },
]
