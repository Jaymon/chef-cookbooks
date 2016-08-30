name = cookbook_name.to_s
n = node[name]


include_recipe "#{name}::authorized_keys"
include_recipe "#{name}::private_keys"
include_recipe "#{name}::known_hosts"


###############################################################################
# reconfigure sshd
###############################################################################
if n.has_key?("sshd_config")

  cache_conf_file = ::File.join(Chef::Config[:file_cache_path], "sshd_config")

  ruby_block "configure sshd" do
    block do

      # build a config file mapping we can manipulate
      conf_lines = []
      conf_lookup = {}

      ::File.read(n["sshd_config_file"]).each_line.with_index do |conf_line, index|

        # this builds a hash of key => value pairs for every config var it finds
        #if conf_line.match(/^[^#]\S+\s/)
        if conf_line.match(/^\S{2,}\s/)
          conf_var, conf_val = conf_line.split(/\s+/, 2)
          if conf_var.start_with?("#")
            conf_var = conf_var[1..-1]
          end
          conf_lookup[conf_var] ||= []
          conf_lookup[conf_var] << index
        end

        conf_line.rstrip!
        conf_lines << conf_line

      end

      # go in and change any values to the new values in the Node
      new_conf_lookup = {}
      new_conf_ignore = Set.new
      n["sshd_config"].each do |key, val|

        # make sure we've got an array
        vals = val.kind_of?(Array) ? val : [val]
        new_conf_lines = []
        vals.each do |v|
          new_conf_lines << "#{key} #{v}"
        end

        # if we have a hit in the original config file, we will put all our values
        # by that first hit line and then ignore all the other lines that had a value for
        # that configuration (ie, our config will override all other config in the file)
        if conf_lookup.has_key?(key)
          new_conf_lookup[conf_lookup[key][0]] = new_conf_lines
          new_conf_ignore.merge(conf_lookup[key])
        else
          # just put lines without previous values at the end of all lines
          conf_lines += [""] + new_conf_lines
        end
      end

      ::File.open(cache_conf_file, "w+") do |f|
        conf_lines.each_with_index do |conf_line, index|
          if new_conf_lookup.has_key?(index)
            f.puts(new_conf_lookup[index])
          else
            if !new_conf_ignore.member?(index)
              f.puts(conf_line)
            end
          end
        end
      end

    end
    notifies :create, "remote_file[#{n["sshd_config_file"]}]", :immediately

  end

  remote_file n['sshd_config_file'] do
    source "file://#{cache_conf_file}"
    mode "0644"
    action :nothing
    notifies :restart, "service[#{name}]", :delayed
  end

end

service name do
  provider Chef::Provider::Service::Upstart
  action :nothing
  supports :start => true, :stop => true, :status => true, :restart => true
end

