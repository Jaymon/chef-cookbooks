###############################################################################
# configures database client
#
# since 5-11-2015
###############################################################################
name_pg = cookbook_name.to_s
name = recipe_name.to_s
n_pg = node[name_pg]
n = n_pg[name]
u = n_pg["user"]
#cmd_user = "sudo -E -u #{u}"


###############################################################################
# install client
###############################################################################
["postgresql-client-common"].each do |p|
  package p
end


###############################################################################
# add client files (psqlrc and pgpass) for all users on the system
###############################################################################

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


# add the .psqlrc file to all the users if it doesn't already exist
# I can't find a reliable way to know where to place a global psqlrc file, this is the 
# closest I've found: http://comments.gmane.org/gmane.comp.db.postgresql.admin/30740
# so I'll just put one in every user
users_home = ::Dir.glob("/home/*/")
users_home << "/root/"
users_home.each do |user_home|

  user = ::File.basename(user_home)

  # add a .pgpass file if the user is one of the postgres users
  if n_pg["users"].has_key?(user)

    # http://wiki.opscode.com/display/ChefCN/Templates
    template ::File.join(user_home, ".pgpass") do
      source "pgpass.erb"
      variables(
        :username => user,
        :password => n_pg["users"][user]
      )
      owner user
      group user
      mode "0600"
      sensitive true
      action :create_if_missing
    end
  end

end


