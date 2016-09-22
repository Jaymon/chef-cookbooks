###############################################################################
# installs the postgresql databases into postgres
#
# This is more of an internal recipe, it is called from default and configures the
# postgres databases, it requires the db being created and the node["postgres"]["user"]
# being created in order to work, that's why it is internal
# 
# since 9-20-2016
###############################################################################
name_pg = cookbook_name.to_s
name = recipe_name.to_s
n_pg = node[name_pg]
n = n_pg[name]
admin = ::Postgres::User.new(n_pg['user'])


n.each do |dbname, options|

  # create the db
  owner = options.fetch("owner", "")
  if !owner.empty?
    execute admin.create_db_command(dbname, owner) do
      action :run
      not_if { admin.db_exists?(dbname) }
      # http://stackoverflow.com/questions/8392973/understanding-chef-only-if-not-if
    end

  end

  # add any read only users to the db
  read_users = Array(options.fetch("read", []))

  #owner = ::Postgres::User.new(owner)
  read_users.each do |username|
    # user should be able to connect to the database and create temp tables
    execute admin.get_command("GRANT CONNECT ON DATABASE #{dbname} TO #{username}")
    execute admin.get_command("GRANT TEMP ON DATABASE #{dbname} TO #{username}")

    # now let the user have access to all the current tables in the db
    query = "GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO #{username}"
    execute admin.get_command(query, dbname)

    query = "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO #{username}"
    execute admin.get_command(query, dbname)

    query = "GRANT SELECT ON ALL TABLES IN SCHEMA public TO #{username}"
    execute admin.get_command(query, dbname)

    if owner.empty?
      log "#{username} cannot read tables created in the future unless an owner is specified" do
        level :warn
      end

      log "You need to specify an owner and re-run this recipt for #{username} to read new tables" do
        level :warn
      end

    else
      # inherit future also
      query = "ALTER DEFAULT PRIVILEGES FOR USER #{owner} IN SCHEMA public GRANT USAGE ON SEQUENCES TO #{username}"
      execute admin.get_command(query, dbname)

      query = "ALTER DEFAULT PRIVILEGES FOR USER #{owner} IN SCHEMA public GRANT SELECT ON SEQUENCES TO #{username}"
      execute admin.get_command(query, dbname)

      query = "ALTER DEFAULT PRIVILEGES FOR USER #{owner} IN SCHEMA public GRANT SELECT ON TABLES TO #{username}"
      execute admin.get_command(query, dbname)

    end

  end

end

