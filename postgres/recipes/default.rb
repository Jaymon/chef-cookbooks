###############################################################################
# installs the postgresql db on ubuntu
#
# I found all the sql commands using this page: http://www.postgresql.org/docs/8.0/static/catalogs.html
# http://www.postgresql.org/docs/8.0/static/app-psql.html
# http://sqlrelay.sourceforge.net/sqlrelay/gettingstarted/postgresql.html
# 
# the reason why we do sudo -u postgres is because setting user "postgres" doesn't work the way I thought
# it would work, so the only way to execute these commands as the postgres user is to do the sudo hack
###############################################################################

name = cookbook_name.to_s
n = node[name]
u = node[name]["user"]
cmd_user = "sudo -u #{u}"


###############################################################################
# setup the locale if needed
#
# Even though I'd been using this recipe for quite a while, all of a sudden Postgres is
# snippy about the locale of the box to use unicode, so let's set it
###############################################################################
# TODO: would this be better to just run:
# update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
pg_locale_default = "en_US.UTF-8"
pg_locale = ""
locales = ["LC_COLLATE", "LANG", "LANGUAGE", "LC_CTYPE", "LC_ALL"]
locales_prev = {}
locales.each do |locale|
  if ENV.has_key?(locale)
    pg_locale = ENV[locale]
    break
  end
end

if pg_locale.empty?
  ruby_block "set postgres locale" do
    block do
      locales.each do |locale|
        if ENV.has_key?(locale)
          locales_prev[locale] = ENV[locale]
        end

        ENV[locale] = pg_locale_default
      end
    end
    action :create
  end
end

pg_locale = pg_locale_default


###############################################################################
# actually install postgres db
###############################################################################

["postgresql", "postgresql-contrib"].each do |p|
  package p
end


###############################################################################
# add the postgres users and passwords
###############################################################################

# Originally this used createuser command line utility
# http://www.postgresql.org/docs/9.3/static/app-createuser.html

##
# this will create the query to either add or update the user's priviledges
#
# http://www.postgresql.org/docs/9.3/static/sql-createrole.html
# http://www.postgresql.org/docs/9.3/static/sql-alterrole.html
##
def make_query(username, options, is_create)

  query = is_create ? "CREATE USER" : "ALTER USER"
  query += " #{username} WITH"

  options.each do |k, v|

    if v.is_a?(TrueClass)
      query += " #{k.upcase}"

    elsif v.is_a?(FalseClass)
      query += " NO#{k.upcase}"

    else
      query += " #{k.upcase} '#{v}'"

    end

  end

  query

end

n["users"].each do |username, options|

  user_exists = "psql -c \"select usename from pg_user where usename='#{username}'\" -d template1 | grep -w \"#{username}\""

  # this will run to alter the user to be how we want if the user already exists
  cmd = "psql -c \"#{make_query(username, options, false)}\" -d template1"
  execute "#{cmd_user} #{cmd}" do
    action :run
    only_if "#{cmd_user} #{user_exists}"
  end

  # this will only run if the user doesn't already exist
  cmd = "psql -c \"#{make_query(username, options, true)}\" -d template1"
  execute "#{cmd_user} #{cmd}" do
    action :run
    not_if "#{cmd_user} #{user_exists}"
  end

end


###############################################################################
# add the databases
###############################################################################
n["databases"].each do |username, dbnames|

  Array(dbnames).each do |dbname|

    #cmd = "createdb --template=template0 -E UTF8 --locale=en_US.utf8 -O #{username} #{dbname}"
    cmd = "createdb -E UTF8 --locale=#{pg_locale} -O #{username} #{dbname}"
    not_cmd = "psql -c \"select datname from pg_database where datname='#{dbname}'\" -d template1 | grep -w \"#{dbname}\""
    # test to see if this works
    # http://stackoverflow.com/questions/8392973/understanding-chef-only-if-not-if
    #not_cmd = 'psql --list|grep #{dbname}', :user => username
    execute "#{cmd_user} #{cmd}" do
      action :run
      #ignore_failure true
      not_if "#{cmd_user} #{not_cmd}"
    end
  end

end


###############################################################################
# add psqlrc files for all users on the system
###############################################################################
# add the .psqlrc file to all the users if it doesn't already exist
# I can't find a reliable way to know where to place a global psqlrc file, this is the 
# closest I've found: http://comments.gmane.org/gmane.comp.db.postgresql.admin/30740
# so I'll just put one in every user
users_home = Dir.glob("/home/*/")
users_home << "/root/"
users_home.each do |user_home|

  user = File.basename(user_home)

  # there could aslo one be placed somewhere and PSQLRC environment variable set
  # to that location
  # http://www.postgresql.org/docs/9.2/static/app-psql.html

  # http://wiki.opscode.com/display/chef/Resources#Resources-CookbookFile
  cookbook_file File.join(user_home,".psqlrc") do
    backup false
    source "psqlrc.sh"
    owner user
    group user
    mode "0644"
    action :create_if_missing
  end

  # add a .pgpass file if the user is one of the postgres users
  if n["users"].has_key?(user)

    # http://wiki.opscode.com/display/ChefCN/Templates
    template File.join(user_home,".pgpass") do
      source "pgpass.erb"
      variables(
        :username => user,
        :password => n["users"][user]
      )
      owner user
      group user
      mode "0600"
      action :create_if_missing
    end
  end

end


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



###############################################################################
# cleanup
###############################################################################
ruby_block "reset previous locale" do
  block do 
    if locales_prev
      # remove previous locales
      locales.each do |locale|
        ENV.delete(locale)
      end

      # restore previous values
      locales_prev.each do |locale, locale_val|
        ENV[locale] = locale_val
      end
    end
  end
  action :create
end

