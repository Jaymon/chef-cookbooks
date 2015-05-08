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


require 'pp'
p "============================================================================"
p "============================================================================"
p name_pg
p name
p "============================================================================"
PP.pp(n_pg)
p "============================================================================"
PP.pp(n)
p "============================================================================"
p "============================================================================"

###############################################################################
# replication
###############################################################################
if !n.empty?

  recovery_file = ::File.join(n_pg["main_dir"], "recovery.conf")
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
    command "rm -rf #{n_pg["data_dir"]}"
    action :nothing
    notifies :run, "execute[pg_basebackup]", :immediately
  end

  basebackup_cmd = "#{cmd_user} pg_basebackup -h #{host}"
  if !port.empty?
    basebackup_cmd += " -p #{port}"
  end
  basebackup_cmd += " -D #{n_pg["data_dir"]} -U #{n["user"]} -X stream --write-recovery-conf"

  execute "pg_basebackup" do
    command basebackup_cmd
    action :nothing
    sensitive true
    environment(
      "PGPASSWORD" => n["password"]
    )
    #notifies :create_if_missing, "template[pg_recovery]", :immediately
    notifies :start, "service[#{name_pg}]", :delayed
  end

  template "pg_recovery" do
    path recovery_file
    source "recovery.conf.erb"
    variables(
      "user" => n["user"],
      "host" => host,
      "port" => port,
      "password" => n["password"],
      "trigger_file" => n["trigger_file"]
    )
    owner u
    group u
    mode "0600"
    action :nothing
    notifies :start, "service[#{name_pg}]", :delayed
  end

end

