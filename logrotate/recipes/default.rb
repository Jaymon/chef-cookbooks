name = cookbook_name.to_s
n = node[name]


# https://www.digitalocean.com/community/tutorials/how-to-manage-log-files-with-logrotate-on-ubuntu-12-10
package "logrotate"

[:set, :merge].each do |lr_action|
  n[lr_action].each do |logname, val|

    resource_name = "#{name} #{lr_action.to_s} #{logname}"
    temp_path = ::File.join(Chef::Config[:file_cache_path], resource_name)
    path = ::Logrotate.new(logname).path()

    ruby_block "configure #{resource_name}" do
      block do
        lr = ::Logrotate.new(logname)

        val.each do |log, config|
          if lr_action == :merge
            if lr.has?
              lr.merge(log, config)
            end

          else
            lr.set(log, config)
          end
        end

        lr.write_file(temp_path)

      end # block
      notifies :create, "remote_file[file #{resource_name}]", :delayed

    end # ruby_block

    remote_file "file #{resource_name}" do
      path path
      source "file://#{temp_path}"
      only_if "test -f '#{temp_path}'"
      action :nothing
    end

  end
end

