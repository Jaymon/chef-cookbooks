# https://github.com/chef-cookbooks/ssh_known_hosts
#::Chef::Resource::User.send(:include, Ssh::Helper)

name = cookbook_name.to_s
known_hosts_d = node[name][recipe_name.to_s]

hosts = known_hosts_d.fetch("hosts", [])


if !hosts.empty?

  users = known_hosts_d.fetch("users", node[name].fetch("users", []))

  users.each do |username|

    home_d = get_homedir(username)
    if !home_d.empty?
      known_hosts_d = ::File.join(home_d, ".ssh")
      known_hosts_f = ::File.join(known_hosts_d, "known_hosts")

      directory "#{username} #{recipe_name.to_s} #{known_hosts_d}" do
        path known_hosts_d
        owner username
        group username
        mode "0700"
        action :create
      end

      file "#{username} #{known_hosts_f}" do
        path known_hosts_f
        owner username
        group username
        mode "0600"
        action :create
      end

      hosts.each do |host|
        cache_f = ::File.join(::Chef::Config[:file_cache_path], "ssh-#{host}-known_hosts")

        execute "#{username} ssh known_hosts create #{host}" do
          command "ssh-keyscan -t rsa -H #{host} >> \"#{cache_f}\""
          notifies :run, "execute[#{username} ssh known_hosts copy #{host}]", :immediately
          not_if "test -f \"#{cache_f}\""
        end

        execute "#{username} ssh known_hosts copy #{host}" do
          command "cat \"#{cache_f}\" >> \"#{known_hosts_f}\""
          action :nothing
        end

      end

    end
  end
end

