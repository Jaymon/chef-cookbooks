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


  #conf_file = Postgres.get_conf_file(version)
  #cache_conf_file = ::File.join(Chef::Config[:file_cache_path], "postgresql.conf")

  # copy ssl cert if in conf
#   if n["ssl_files"] and n["ssl_files"]["ssl_cert_file"]
#     if not n["conf"]["ssl_cert_file"]
#       raise("ssl_cert_file has not been specified in postgres config")
#     end
# 
#     # remove the single-quotes on the ssl_cert_file value
#     remote_file n["conf"]["ssl_cert_file"].tr("'", "") do
#       source "file://#{ n["ssl_files"]["ssl_cert_file"]}"
#       owner "root"
#       group "root"
#       mode "0644"
#       action :create
#     end
#   end
# 
#   # copy ssl key if in conf
#   if n["ssl_files"] and n["ssl_files"]["ssl_key_file"]
#     if not n["conf"]["ssl_key_file"]
#       raise("ssl_key_file has not been specified in postgres config")
#     end
# 
#     # remove the single-quotes on the ssl_key_file value
#     remote_file n["conf"]["ssl_key_file"].tr("'", "") do
#       source "file://#{n["ssl_files"]["ssl_key_file"]}"
#       owner "root"
#       group "ssl-cert"
#       mode "0640"
#       action :create
#     end
#   end

conf = nil

# setting the configuration is in a block because we need postgres to be installed
# because the path to the configuration is dependant on the installed version, so
# we use the block to make sure the paths exist
ruby_block "#{name} configure" do
  block do
    conf = PostgresConf.new(version)
    conf.update!(n["config"])
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



#   hba_file = Postgres.get_hba_file(version)
#   cache_hba_file = ::File.join(Chef::Config[:file_cache_path], "pg_hba.conf")
# 
#   ruby_block "configure pg_hba" do
#     block do
#       # build a file mapping we can manipulate
#       conf_lines = []
#       conf_lookup = []
#       ::File.read(hba_file).each_line.with_index do |conf_line, index|
#         conf_line.strip!
#         conf_lines << conf_line
# 
#         if conf_line =~ /^#/
#           next
# 
#         elsif conf_line =~ /^\s*$/
#           next
# 
#         else
#           conf_line.strip!
#           conn_type, database, user, remainder = conf_line.split(/\s+/, 4)
#           ip6 = false
# 
#           if conn_type == 'local'
#             method, options = remainder.split(/\s+/, 2)
#             address = ''
# 
#           else
#             address, method, options = remainder.split(/\s+/, 3)
#             if address =~ /^::/
#               ip6 = true
#             end
# 
#           end
# 
#           options ||= ''
# 
#           d = {
#             'index' => index,
#             'ip6' => ip6,
#             'connection' => conn_type,
#             'database' => database,
#             'user' => user,
#             'method' => method,
#             'address' => address,
#             'options' => options
#           }
#           conf_lookup << d
#         end
#       end
# 
#       default_row = {
#         'method' => '',
#         'address' => '',
#         'options' => ''
#       }
# 
#       (n['hba_default'] + n['hba']).each do |row|
#         index = -1
#         conf_lookup.each do |conf_row|
#           is_match = true
#           ['connection', 'database', 'user'].each do |k|
#             if conf_row[k] != row[k]
#               is_match = false
#               break
#             end
#           end
# 
#           if is_match
#             if row['address'] =~ /^::/
#               if conf_row['ip6']
#                 index = conf_row['index']
#                 break
#               end
# 
#             else
#               index = conf_row['index']
#               break
#             end
# 
#           end
# 
#         end
# 
#         ncrow = default_row.merge(row)
#         ncl = "#{ncrow['connection']} " + 
#           "#{ncrow['database']} " + 
#           "#{ncrow['user']} " + 
#           "#{ncrow['address']} " +
#           "#{ncrow['method']} " + 
#           "#{ncrow['options']}"
# 
#         # NOTE -- if you set it to active=false and then back to active=true it
#         # will make another row, this is a bug, but a forgivable one for now
#         if !ncrow.fetch('active', true)
#           ncl = "##{ncl}"
#         end
# 
#         if index >= 0
#           conf_lines[index] = ncl
# 
#         else
#           conf_lines << ncl
# 
#         end
# 
#       end
# 
#       ::File.open(cache_hba_file, "w+") do |f|
#         f.puts(conf_lines)
#       end
# 
#     end
#     notifies :create, "remote_file[#{hba_file}]", :delayed
#   end
# 
#   remote_file hba_file do
#     source "file://#{cache_hba_file}"
#     owner u
#     group u
#     mode "0644"
#     action :nothing
#     notifies :restart, "service[#{name}]", :delayed
#   end


###############################################################################
# manage the postgres service
###############################################################################

# http://wiki.opscode.com/display/chef/Resources#Resources-Service
service name do
  service_name "postgresql"
  #supports :restart => true, :reload => false, :start => true, :stop => true, :status => true
  #action :nothing
end

