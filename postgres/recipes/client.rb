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


["postgresql-client"].each do |p|
  package p
end


# place a global psqlrc file that all users will inherit
# The system-wide startup file is named psqlrc and is sought in the installation's
# "system configuration" directory, which is most reliably identified by running
# pg_config --sysconfdir. By default this directory will be ../etc/ relative to
# the directory containing the PostgreSQL executables. The name of this directory
# can be set explicitly via the PGSYSCONFDIR environment variable.
# http://www.postgresql.org/docs/9.2/static/app-psql.html
cookbook_file ::File.join(n_pg["system_conf_dir"], "psqlrc") do
  source "psqlrc.sh"
  owner u
  group u
  mode "0644"
  action :create
end
# there could also one be placed somewhere and PSQLRC environment variable set
# to that location
# http://www.postgresql.org/docs/9.2/static/app-psql.html


n_pg["users"].each do |username, options|

  user = ::Postgres::User.new(username)
  user_home = user.homedir

  if !user_home.empty?
    # http://wiki.opscode.com/display/ChefCN/Templates
    # https://www.postgresql.org/docs/9.5/static/libpq-pgpass.html
    # hostname:port:database:username:password
    template ::File.join(user_home, ".pgpass") do
      source "pgpass.erb"
      variables(
        :username => username,
        :password => options.fetch("password", "*")
      )
      owner username
      group username
      mode "0600"
      sensitive true
      action :create_if_missing
      only_if "test -d #{user_home}"
    end

  end

end

