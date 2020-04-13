###############################################################################
# installs the postgresql db on ubuntu
#
# This recipe will also run client, users, and databases, you will have to run any other
# recipes separately
#
###############################################################################

name = cookbook_name.to_s
n = node[name]
u = n["user"]
version = n["version"]


###############################################################################
# installation
###############################################################################

# TODO -- check for an existing postgres installation and if version and current_version
# are different then we would need to uninstall the current postgres in order to
# upgrade, what it currently does is install the new version but keeps the existing
# version, which is strange
# https://stackoverflow.com/questions/13733719/which-version-of-postgresql-am-i-running

# https://www.postgresql.org/download/linux/ubuntu/
# https://askubuntu.com/questions/633919/how-install-postgresql-9-4
# https://askubuntu.com/questions/638725/install-postgres-9-4-on-ubuntu-14-04-2

# deb <uri> <distribution> <components>
# /etc/apt/sources.list.d/pgdg.list
apt_repository 'pgdg' do
  uri "http://apt.postgresql.org/pub/repos/apt/"
  distribution "#{Postgres.get_os_release()}-pgdg"
  components ['main']
  key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
  keyserver false
  notifies :update, "apt_update[#{name}-repo-update]", :immediately
end

apt_update "#{name}-repo-update" do
  action :nothing
end


if ::Chef::VersionString.new(version) < ::Chef::VersionString.new("10")

  ::Chef::Log.warn("Support for postgres < 10 with this cookbook is NOT tested")
  ["postgresql-#{version}", "postgresql-contrib-#{version}"].each do |p|
    package p
  end

else

  # the contrib package is included in the default package in 10+
  package "postgresql-#{version}"

end


###############################################################################
# setup
###############################################################################

include_recipe "#{name}::users"
include_recipe "#{name}::client"
include_recipe "#{name}::databases"


###############################################################################
# deal with the postgres configuration file
###############################################################################

conf = nil
config = n["config"].to_h

# we will modify the config hash here to make sure ssl is setup if we have defined
# the ssl key/cert in the postgres configuration block. Our modified config hash
# will be passed to PostgresConf to generate the configuration file PostgreSQL will
# ultimately use
if n.has_key?("ssl_key") && n.has_key?("ssl_cert")

  config["ssl"] = true

  ssl_key_path = config.has_key?("ssl_key_file") ? config["ssl_key_file"] : n["ssl_key_default_path"]
  config["ssl_key_file"] = ssl_key_path

  ssl_cert_path = config.has_key?("ssl_cert_file") ? config["ssl_cert_file"] : n["ssl_cert_default_path"]
  config["ssl_cert_file"] = ssl_cert_path

  remote_file ssl_key_path do
    source "file://#{n["ssl_key"]}"
    group "ssl-cert"
    mode "0640"
    action :create
  end

  remote_file ssl_cert_path do
    source "file://#{n["ssl_cert"]}"
    mode "0644"
    action :create
  end

end


# setting the configuration is in a block because we need postgres to be installed
# because the path to the configuration is dependant on the installed version, so
# we use the block to make sure the paths exist
ruby_block "#{name} configure" do
  block do
    conf = PostgresConf.new(version)
    conf.update!(config)
  end
end

file "#{name} save configuration" do
  path lazy { conf.path }
  content lazy { conf.to_s }
  owner u
  group u
  mode "0644"
  notifies :restart, "service[#{name}]", :delayed
end


###############################################################################
# reconfigure pg_hba
###############################################################################
# http://stackoverflow.com/questions/1287067/unable-to-connect-postgresql-to-remote-database-using-pgadmin

hba = nil

ruby_block "#{name} hba configure" do
  block do
    hba = PostgresHba.new(version)
    hba.update!(n.fetch('hba_default', []) + n.fetch('hba', []))
  end
end

file "#{name} save hba" do
  path lazy { hba.path }
  content lazy { hba.to_s }
  owner u
  group u
  mode "0644"
  notifies :restart, "service[#{name}]", :delayed
end


###############################################################################
# manage the postgres service
###############################################################################

# http://wiki.opscode.com/display/chef/Resources#Resources-Service
service name do
  service_name "postgresql"
end

