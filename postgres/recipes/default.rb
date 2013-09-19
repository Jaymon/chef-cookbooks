##
# installs the postgresql db on ubuntu
#
# I found all the sql commands using this page: http://www.postgresql.org/docs/8.0/static/catalogs.html
# http://www.postgresql.org/docs/8.0/static/app-psql.html
# http://sqlrelay.sourceforge.net/sqlrelay/gettingstarted/postgresql.html
# 
# the reason why we do sudo -u postgres is because setting user "postgres" doesn't work the way I thought
# it would work, so the only way to execute these commands as the postgres user is to do the sudo hack
##

# Even though I'd been using this recipe for quite a while, all of a sudden Postgres is
# snippy about the locale of the box to use unicode, so let's set it
name = cookbook_name.to_s
n = node[name]

locales = ["LC_COLLATE", "LC_CTYPE", "LC_ALL", "LANG", "LANGUAGE"]
locales_prev = {}

ruby_block "set postgres locale" do
  block do
    locales.each do |locale|
      if ENV.has_key?(locale)
        locales_prev[locale] = ENV[locale]
      end

      ENV[locale] = "en_US.utf8"
    end
  end
  action :create
end

package "postgresql" do
  action :install
end

package "postgresql-contrib" do
  action :install
end

# add the postgres users and passwords
n["users"].each do |username, password|

  # add the user
  # http://www.postgresql.org/docs/8.1/static/app-createuser.html
  cmd = "createuser --no-superuser --createdb --no-createrole --echo #{username}"
  not_cmd = "psql -c \"select usename from pg_user where usename='#{username}'\" -d template1 | grep -w \"#{username}\""
  execute "sudo -u postgres #{cmd}" do
    user "root"
    action :run
    #ignore_failure true
    not_if "sudo -u postgres #{not_cmd}"
  end
  
  # set the user's password, we run this every time so updated passwords get changed
  cmd = "psql -c \"ALTER USER #{username} WITH PASSWORD '#{password}'\" -d template1"
  execute "sudo -u postgres #{cmd}" do
    user "root"
    action :run
    #ignore_failure true
  end

end
    
# add databases
n["databases"].each do |username, dbnames|

  Array(dbnames).each do |dbname|

    #cmd = "createdb --template=template0 -E UTF8 --locale=en_US.utf8 -O #{username} #{dbname}"
    cmd = "createdb -E UTF8 --locale=en_US.utf8 -O #{username} #{dbname}"
    not_cmd = "psql -c \"select datname from pg_database where datname='#{dbname}'\" -d template1 | grep -w \"#{dbname}\""
    execute "sudo -u postgres #{cmd}" do
      user "root"
      action :run
      #ignore_failure true
      not_if "sudo -u postgres #{not_cmd}"
    end
    
  end

end
    
# add the .psqlrc file to all the users if it doesn't already exist
# I can't find a reliable way to know where to place a global psqlrc file, this is the 
# closest I've found: http://comments.gmane.org/gmane.comp.db.postgresql.admin/30740
# so I'll just put one in every user
users_home = Dir.glob("/home/*/")
users_home << "/root/"
users_home.each do |user_home|

  user = File.basename(user_home)
  
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
    
# http://wiki.opscode.com/display/chef/Resources#Resources-Service
service "postgres" do
  service_name "postgresql"
  supports :restart => true, :reload => false, :start => true, :stop => true, :status => true
  action :nothing
end

ruby_block "reset previous locale" do
  block do 
    # remove previous locales
    locales.each do |locale|
      ENV.delete(locale)
    end

    # restore previous values
    locales_prev.each do |locale, locale_val|
      ENV[locale] = locale_val
    end
  end
  action :create
end

