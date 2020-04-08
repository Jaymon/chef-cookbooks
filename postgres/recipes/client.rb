###############################################################################
# configures database client
#
# since 5-11-2015
###############################################################################
name_pg = cookbook_name.to_s
name = recipe_name.to_s
n_pg = node[name_pg]
n = n_pg.fetch(name, {})
u = n_pg["user"]
version = n_pg["version"]
system_conf_dir = Postgres.get_system_conf_dir(version)


["postgresql-client-#{version}"].each do |p|
  package p
end


# place a global psqlrc file that all users will inherit
# The system-wide startup file is named psqlrc and is sought in the installation's
# "system configuration" directory, which is most reliably identified by running
# pg_config --sysconfdir. By default this directory will be ../etc/ relative to
# the directory containing the PostgreSQL executables. The name of this directory
# can be set explicitly via the PGSYSCONFDIR environment variable.
# http://www.postgresql.org/docs/9.2/static/app-psql.html
cookbook_file ::File.join(system_conf_dir, "psqlrc") do
  source "psqlrc.sh"
  # NOTE 12-22-2016, if this file is installed by itself "postgres" user doesn't
  # exist and that will cause provision to fail, testing it looks like this file
  # being root works just find
  #owner u
  #group u
  mode "0644"
  action :create
end
# you could also place a PSQLRC environment variable
# to that location
# http://www.postgresql.org/docs/9.2/static/app-psql.html


n_pg["users"].each do |username, options|

  user = PostgresUser.new(username)
  user_home = user.homedir

  # we only want to add a pgpass for the user if they exist on the system
  if !user_home.empty?
    # http://wiki.opscode.com/display/ChefCN/Templates
    # https://www.postgresql.org/docs/9.5/static/libpq-pgpass.html
    # hostname:port:database:username:password
    template ::File.join(user_home, ".pgpass") do
      source "pgpass.erb"
      variables(
        :rows => user.pgpasses(options),
      )
      owner username
      group username
      mode "0600"
      sensitive true
      action :create
      only_if "test -d #{user_home}"
    end
  end

end

