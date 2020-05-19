# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "postgres"

n = {}

# the user that will run postgres, best not to change this
n["user"] = "postgres"

n["users"] = {}
n["databases"] = {}

n["version"] = "12"

n["config"] = {}
n["config"]["listen_addresses"] = "*"
n["config"]["port"] = 5432

n["client"] = {
  "host": "localhost",
  "port": n["config"]["port"],
}

n["ssl_cert_default_path"] = "/etc/ssl/certs/postgres.crt"
n["ssl_key_default_path"] = "/etc/ssl/private/postgres.key"

n["hba"] = []

# so here's the problem, I want these to pretty much always be around in the majority
# of the cases. The problem is if we add any hba values in a config, it would overwrite these :(
# so we could either make hba a dict with named keys or user keys, but then you would
# still need to get all the keys if you needed to clear all the defaults, my solution
# is this hack, these will be added to the hba file and then the hba values will be added
# to the file, which can overwrite these values. It's a hack, but it works and allows you to
# completely blow the defaults away by setting it to an empty list
n["hba_default"] = [
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
    'address' => '0.0.0.0/0', # '127.0.0.1/32' would allow only local connections
    'method' => 'md5',
  },
  { # allow remote host connection using ssl
    'connection' => 'hostssl',
    'database' => 'all',
    'user' => 'all',
    'address' => "0.0.0.0/0",
    'method' => 'md5',
  },
]

default[name] = n

