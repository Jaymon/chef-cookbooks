###############################################################################
# installs the postgresql db on ubuntu
#
# This recipe will also run users and databases, you will have to run any other
# recipes separately
#
###############################################################################

name = cookbook_name.to_s
n = node[name]
u = n["user"]


###############################################################################
# actually install postgres db
###############################################################################

["postgresql", "postgresql-contrib"].each do |p|
  package p
end


include_recipe "#{name}::users"
include_recipe "#{name}::client" # this configures the client
include_recipe "#{name}::databases"


###############################################################################
# manage the postgres service
###############################################################################

# http://wiki.opscode.com/display/chef/Resources#Resources-Service
service name do
  service_name "postgresql"
  supports :restart => true, :reload => false, :start => true, :stop => true, :status => true
  action :nothing
end


###############################################################################
# reconfigure postgres
###############################################################################

# the code to configure postgres is kind of a chicken/egg problem, on first run
# there is no postgres.conf file to read from, so you can't have this code run
# until postgres is actually installed, so on first run through, the cache_conf_file
# and n['conf_file'] are pointing to files that don't actually exist, which is 
# why we use a ruby_block and notifications

if n.has_key?("conf")

  cache_conf_file = ::File.join(Chef::Config[:file_cache_path], "postgresql.conf")

  # copy ssl cert if in conf
  if n["ssl_files"] and n["ssl_files"]["ssl_cert_file"]
    if not n["conf"]["ssl_cert_file"]
      raise("ssl_cert_file has not been specified in postgres config")
    end

    # remove the single-quotes on the ssl_cert_file value
    remote_file n["conf"]["ssl_cert_file"].tr("'", "") do
      source "file://#{ n["ssl_files"]["ssl_cert_file"]}"
      owner "root"
      group "root"
      mode "0644"
      action :create
    end
  end

  # copy ssl key if in conf
  if n["ssl_files"] and n["ssl_files"]["ssl_key_file"]
    if not n["conf"]["ssl_key_file"]
      raise("ssl_key_file has not been specified in postgres config")
    end

    # remove the single-quotes on the ssl_key_file value
    remote_file n["conf"]["ssl_key_file"].tr("'", "") do
      source "file://#{n["ssl_files"]["ssl_key_file"]}"
      owner "root"
      group "ssl-cert"
      mode "0640"
      action :create
    end
  end

  ruby_block "configure postgres" do
    block do

      # build a config file mapping we can manipulate
      conf_lines = []
      conf_lookup = {}
      ::File.read(n["conf_file"]).each_line.with_index do |conf_line, index|
        if conf_line.match(/^\S+\s*=/)
          conf_var, conf_val = conf_line.split(/\s*=\s*/, 2)
          conf_val, conf_comment = conf_val.split(/#/, 2)

          #conf_val.rstrip!
          if conf_comment
            conf_comment.rstrip!
          else
            conf_comment = ''
          end

          if conf_var[0] == '#'
            conf_var = conf_var[1..-1]
          end
          conf_lookup[conf_var] = [index, conf_comment]

        end

        conf_lines << conf_line

      end

      # modify our config file and write it out to our temp conf file
      n["conf"].each do |key, val|
        conf_line = "#{key} = #{val}"
        if conf_lookup.has_key?(key)
          cb = conf_lookup[key]
          if !cb[1].empty?
            conf_line += " ##{cb[1]}"
          end
          conf_lines[cb[0]] = conf_line

        else
          conf_lines << conf_line

        end

      end

      ::File.open(cache_conf_file, "w+") do |f|
        f.puts(conf_lines)
      end

    end
    notifies :create, "remote_file[#{n['conf_file']}]", :delayed

  end

  remote_file n['conf_file'] do
    source "file://#{cache_conf_file}"
    owner u
    group u
    mode "0644"
    action :nothing
    notifies :restart, "service[#{name}]", :delayed
  end

end


###############################################################################
# reconfigure pg_hba
###############################################################################
# http://stackoverflow.com/questions/1287067/unable-to-connect-postgresql-to-remote-database-using-pgadmin
if n.has_key?("hba")

  # the code to configure postgres is kind of a chicken/egg problem, on first run
  # there is no postgres.conf file to read from, so you can't have this code run
  # until postgres is actually installed, so on first run through, the cache_conf_file
  # and n['conf_file'] are pointing to files that don't actually exist, which is 
  # why we use a ruby_block and notifications

  cache_hba_file = ::File.join(Chef::Config[:file_cache_path], "pg_hba.conf")

  ruby_block "configure pg_hba" do
    block do
      # build a file mapping we can manipulate
      conf_lines = []
      conf_lookup = []
      ::File.read(n["hba_file"]).each_line.with_index do |conf_line, index|
        conf_line.strip!
        conf_lines << conf_line

        if conf_line =~ /^#/
          next

        elsif conf_line =~ /^\s*$/
          next

        else
          conf_line.strip!
          conn_type, database, user, remainder = conf_line.split(/\s+/, 4)
          ip6 = false

          if conn_type == 'local'
            method, options = remainder.split(/\s+/, 2)
            address = ''

          else
            address, method, options = remainder.split(/\s+/, 3)
            if address =~ /^::/
              ip6 = true
            end

          end

          options ||= ''

          d = {
            'index' => index,
            'ip6' => ip6,
            'connection' => conn_type,
            'database' => database,
            'user' => user,
            'method' => method,
            'address' => address,
            'options' => options
          }
          conf_lookup << d
        end
      end

      default_row = {
        'method' => '',
        'address' => '',
        'options' => ''
      }

      (n['hba_default'] + n['hba']).each do |row|
        index = -1
        conf_lookup.each do |conf_row|
          is_match = true
          ['connection', 'database', 'user'].each do |k|
            if conf_row[k] != row[k]
              is_match = false
              break
            end
          end

          if is_match
            if row['address'] =~ /^::/
              if conf_row['ip6']
                index = conf_row['index']
                break
              end

            else
              index = conf_row['index']
              break
            end

          end

        end

        ncrow = default_row.merge(row)
        ncl = "#{ncrow['connection']} " + 
          "#{ncrow['database']} " + 
          "#{ncrow['user']} " + 
          "#{ncrow['address']} " +
          "#{ncrow['method']} " + 
          "#{ncrow['options']}"

        # NOTE -- if you set it to active=false and then back to active=true it
        # will make another row, this is a bug, but a forgivable one for now
        if !ncrow.fetch('active', true)
          ncl = "##{ncl}"
        end

        if index >= 0
          conf_lines[index] = ncl

        else
          conf_lines << ncl

        end

      end

      ::File.open(cache_hba_file, "w+") do |f|
        f.puts(conf_lines)
      end

    end
    notifies :create, "remote_file[#{n['hba_file']}]", :delayed
  end

  remote_file n['hba_file'] do
    source "file://#{cache_hba_file}"
    owner u
    group u
    mode "0644"
    action :nothing
    notifies :restart, "service[#{name}]", :delayed
  end

end


