
# TODO -- update this recipe to work with Ubuntu 18.04 and PostgreSQL 10+
::Chef::Application.fatal!('Replication recipe is way out of date and cannot be used as of April 2020')

# from attributes/default.rb
default[name]["replication"] = {}



# from the README:

# -------------------------------------------------------------------------------
# 
# ### replication
# 
# This will be under `["postgres"]["replication"]` and can contain the following keys:
# 
# * master -- required -- the address of the master server in `host:port` format
# * user -- required -- the name of the user with replication permissions on the master
# * password -- required -- the password the user will use to access the master
# * trigger_file -- optional -- will trigger failover of standby to master if touched
# 
# These are the sources I used to get replication working:
# 
# [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps)
# [post 1](http://www.rassoc.com/gregr/weblog/2013/02/16/zero-to-postgresql-streaming-replication-in-10-mins/)
# [post 2](http://www.brandonlamb.com/posts/postgresql-93-streaming-replication-howto-tutorial)
# [hot standby wiki](https://wiki.postgresql.org/wiki/Hot_Standby)
# [hot standby docs](http://www.postgresql.org/docs/9.3/static/hot-standby.html)
# [stack overflow question 1](http://dba.stackexchange.com/questions/71515/streaming-replication-postgresql-9-3-using-two-different-servers)
# [Github gist](https://gist.github.com/joeyates/d3ca985ce929e515e88d)
# [SO question 2](http://askubuntu.com/questions/531307/postgres-xc-will-not-install-due-to-broken-packages#531316)
# [spiped on standby](http://postgresql.nabble.com/WAL-receive-process-dies-td5816672.html)
# [purge PG](http://stackoverflow.com/questions/2748607/how-to-thoroughly-purge-and-reinstall-postgresql-on-ubuntu)






###############################################################################
# configures replication for this database installation
#
# since 5-8-2015
###############################################################################
name_pg = cookbook_name.to_s
name = recipe_name.to_s
n_pg = node[name_pg]
n = n_pg[name]
u = n_pg["user"]
cmd_user = "sudo -E -u #{u}"


# require 'pp'
# p "============================================================================"
# p "============================================================================"
# p name_pg
# p name
# p "============================================================================"
# PP.pp(n_pg)
# p "============================================================================"
# PP.pp(n)
# p "============================================================================"
# p "============================================================================"

###############################################################################
# replication
###############################################################################
if !n.empty?

  version = n_pg["version"]
  data_dir = Postgres.get_data_dir(version)
  recovery_file = ::File.join(data_dir, "recovery.conf")
  host, port = n["master"].split(":")

  # http://stackoverflow.com/questions/27535197/stop-service-in-chef-after-it-has-been-notified-to-restart
  ruby_block 'pg_stop_service_for_replication' do
    block do
      r = resources("service[#{name_pg}]")
      r.run_action(:stop)
    end
    not_if "test -f #{recovery_file}"
    notifies :run, "execute[pg_clear_data_for_replication]", :immediately
  end

  execute "pg_clear_data_for_replication" do
    command "rm -rf #{data_dir}"
    action :nothing
    notifies :run, "execute[pg_basebackup]", :immediately
  end

  basebackup_cmd = "#{cmd_user} pg_basebackup -h #{host}"
  if !port.empty?
    basebackup_cmd += " -p #{port}"
  end
  # can't use --write-recovery-conf here because it doesn't set a trigger_file :(
  basebackup_cmd += " -D #{data_dir} -U #{n["user"]} -X stream"

  execute "pg_basebackup" do
    command basebackup_cmd
    action :nothing
    sensitive true
    environment(
      "PGPASSWORD" => n["password"] # could also create .pgpass file and use that
    )
    notifies :create_if_missing, "template[pg_recovery]", :immediately
    #notifies :start, "service[#{name_pg}]", :delayed
  end

  template "pg_recovery" do
    path recovery_file
    source "recovery.conf.erb"
    variables(
      "user" => n["user"],
      "host" => host,
      "port" => port,
      "password" => n["password"],
      "trigger_file" => n.fetch("trigger_file", "")
    )
    owner u
    group u
    mode "0600"
    action :nothing
    notifies :start, "service[#{name_pg}]", :delayed
  end

end

