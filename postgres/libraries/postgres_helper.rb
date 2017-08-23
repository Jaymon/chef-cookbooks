# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/

module Postgres

  include ::Chef::Mixin::ShellOut

  ##
  # get the postgres version that will be installed if you ran apt-get, this is
  # handy because it allows you to get the version that will be installed so you
  # can figure out paths that Postgres will use
  ##
  def get_version()
    version_str = shell_out!("apt-cache show postgresql|grep Version")
    m = version_str.stdout.match(/^Version:\s*([\d\.]+)/i)
    return m[1]
  end

  def get_main_dir(version)
    return ::File.join("", "etc", "postgresql", version, "main")
  end

  def get_data_dir(version)
    return ::File.join("", "var", "lib", "postgresql", version, "main")
  end

  def get_system_conf_dir(version)
    return ::File.join("", "etc", "postgresql-common")
  end

  def get_conf_file(version)
    return ::File.join(get_main_dir(version), "postgresql.conf")
  end

  def get_hba_file(version)
    return ::File.join(get_main_dir(version), "pg_hba.conf")
  end

  ##
  # creating an instance of this class will allow you to format queries and run
  # commands and check things on the db from the perspective of the passed in db
  # user
  ##
  class User

    include ::Chef::Mixin::ShellOut

    attr_accessor :username, :cmd_user

    def initialize(username)
      @username = username

      # the reason why we do sudo -u postgres is because setting user "postgres"
      # doesn't work the way I thought it would work, so the only way to execute
      # these commands as the postgres user is to do the sudo hack
      @cmd_user = "sudo -u #{username}"
    end

    def pgpasses(options)
      # hostname:port:database:username:password
      pgpasses = options.fetch("pgpass", []).dup
      if pgpasses.count > 0
        pgpasses.map! { |pgpass|
          if pgpass.has_key?("hostname")
            pgpass["host"] ||= pgpass["hostname"]
          end
          pgpass["password"] ||= options.fetch("password", "*")
          pgpass["username"] ||= @username
          ["host", "port", "database"].each do |k|
            pgpass[k] ||= "*"
          end

          pgpass

        }

      else
        pgpasses << {
          "host" => "*",
          "port" => "*",
          "database" => "*",
          "password" => options.fetch("password", "*"),
          "username" => @username,
        }
      end

      p pgpasses
      return pgpasses

    end

    ##
    # return the home directory path of the initialized user
    ##
    def homedir()
      cmd = shell_out!("grep -e \"^#{username}:\" /etc/passwd | cut -d\":\" -f6")
      return cmd.stdout.strip
    end

    ##
    # return true if the given user already exists in the database
    ##
    def user_exists?(username)
      query = "select usename from pg_user where usename='#{username}'"
      #user_exists = "psql -c \"#{query}\" -d template1 | grep -w \"#{username}\""
      user_exists = "psql -c \"#{query}\" -d template1"
      ::Chef::Log.info(user_exists)
      cmd = shell_out!("#{@cmd_user} #{user_exists}", {:returns => [0]})
      #return cmd.stderr.empty? && (cmd.stdout =~ /\b#{username}\b/)
      return cmd.stdout =~ /\b#{username}\b/
    end

    ##
    # returns a command that can be run to create the username, the options are
    # specified in the chef configuration
    ##
    def create_user_command(username, options)
      cmd = "#{@cmd_user} psql -c \"#{make_user_query(username, options, true)}\" -d template1"
      ::Chef::Log.info(cmd)
      return cmd
    end

    ##
    # returns a command that can be run to update the username, the options are
    # specified in the chef configuration
    ##
    def update_user_command(username, options)
      cmd = "#{@cmd_user} psql -c \"#{make_user_query(username, options, false)}\" -d template1"
      ::Chef::Log.info(cmd)
      return cmd
    end

    ##
    # return true if the database exists
    ##
    def db_exists?(dbname)
      query = "select datname from pg_database where datname='#{dbname}'"
      db_exists = "psql -c \"#{query}\" -d template1 | grep -w \"#{dbname}\""
      ::Chef::Log.info(db_exists)
      cmd = shell_out!("#{@cmd_user} #{db_exists}", {:returns => [0, 1]})
      return cmd.stdout =~ /\b#{dbname}\b/
    end

    ##
    # returns a command to create a database, owned by owner (username)
    ##
    def create_db_command(dbname, owner, options)
      encoding = options.fetch("encoding", "UTF8")
      pg_locale = options.fetch("locale", "en_US.UTF-8")
      cmd = "#{@cmd_user} createdb -E #{encoding} --locale=#{pg_locale} -O #{owner} #{dbname}"
      return cmd
    end

    ##
    # this returns the query, to be run on the given db (if provided), that you can
    # run on the command line
    ##
    def get_command(query, dbname="")
      if dbname.empty?
        cmd = "#{@cmd_user} psql -c \"#{query}\""
      else
        cmd = "#{@cmd_user} psql -d \"#{dbname}\" -c \"#{query}\""
      end
      return cmd
    end

    ##
    # this will create the query to either add or update the user's priviledges
    #
    # Originally this used createuser command line utility
    # http://www.postgresql.org/docs/9.3/static/app-createuser.html
    #
    # http://www.postgresql.org/docs/9.3/static/sql-createrole.html
    # http://www.postgresql.org/docs/9.3/static/sql-alterrole.html
    ##
    def make_user_query(username, user_options, is_create)

      options = user_options.fetch("options", {}).to_hash # just in case it's from the node
      if user_options.has_key?("password")
        options["ENCRYPTED PASSWORD"] = user_options["password"]
      end

      query = is_create ? "CREATE USER" : "ALTER USER"
      query += " #{username} WITH"
      opts = options.map { |k, v| [k.upcase, v] }.to_h

      opts.each do |k, v|
        if v.is_a?(TrueClass)
          query += " #{k}"

        elsif v.is_a?(FalseClass)
          query += " NO#{k}"

        elsif v.is_a?(Integer)
          query += " #{k} #{v}"

        else
          query += " #{k} '#{v}'"

        end

      end

      return query

    end

  end

end


# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
#::Chef::Recipe.send(:include, Postgres::Helper)
#::Chef::Recipe.send(:include, Postgres)
::Chef::Recipe.send(:include, ::Postgres)
# Chef::Resource.send(:include, ::Postgres::Helper)
# Chef::Provider.send(:include, ::Postgres::Helper)
::Chef::Node::Attribute.send(:include, ::Postgres)

