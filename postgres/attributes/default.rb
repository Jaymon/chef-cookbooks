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

# pgbouncer specific configuration
default[name]["pgbouncer"] = {}
default[name]["pgbouncer"]["src_dir"] = ::File.join(::Chef::Config[:file_cache_path], name, "pgbouncer")
default[name]["pgbouncer"]["src_repo"] = "https://github.com/markokr/pgbouncer-dev.git"
default[name]["pgbouncer"]["version"] = "1.5.4"

default[name]["pgbouncer"]["databases"] = {
  '*' => "host=127.0.0.1 port=5432", # fallback connection string
}

default[name]["pgbouncer"]["pgbouncer"] = {
  'logfile' => ::File.join("", "var", "log", "pgbouncer", "pgbouncer.log"),
  'pidfile' => ::File.join("", "var", "run", "pgbouncer", "pgbouncer.pid"),
  'unix_socket_dir' = ::File.join("", "var", "run", "pgbouncer"),
  'auth_file' => ::File.join("", "etc", "pgbouncer", "userlist.txt"),
  "listen_addr" => "127.0.0.1", # "*" might be better default
  "listen_port" => 6432,
  "pool_mode" => "session",
  "max_client_conn" => 100,
  "default_pool_size" => 20,
  "log_connections" => 1, 
  "log_disconnections" => 1, 
  "log_pooler_errors" => 1,
  "server_check_delay" => 30,
  "server_lifetime" => 3600,
  "server_idle_timeout" => 600,
  "client_login_timeout" => 60,
  "listen_backlog" => 200
  #"server_reset_query" => "DISCARD ALL",
  #"auth_type" => "md5",
}


