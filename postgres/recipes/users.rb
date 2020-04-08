###############################################################################
# installs the postgres users
#
# This is more of an internal recipe, it is called from default and configures the
# postgres users, it requires the db being created and the node["postgres"]["user"]
# being created in order to work, that's why it is internal
#
# I found all the sql commands using these page: 
# http://www.postgresql.org/docs/8.0/static/catalogs.html
# http://www.postgresql.org/docs/8.0/static/app-psql.html
# http://sqlrelay.sourceforge.net/sqlrelay/gettingstarted/postgresql.html
# 
# since 9-19-2016
###############################################################################
name_pg = cookbook_name.to_s
name = recipe_name.to_s
n_pg = node[name_pg]
n = n_pg[name]
admin = PostgresUser.new(n_pg['user'])


n.each do |username, options|

  # this will only run if the user doesn't already exist
  execute "create pg user #{username}" do
    command admin.create_user_command(username, options)
    action :run
    sensitive true
    not_if { admin.user_exists?(username) }
  end

  # this will run to alter the user to be how we want if the user already exists
  execute "alter pg user #{username}" do
    command admin.update_user_command(username, options)
    action :run
    sensitive true
    only_if { admin.user_exists?(username) }
  end

end

