name = cookbook_name.to_s
n = node[name]

###############################################################################
# build prototype ini file to use as a base for all the apps
###############################################################################
ini_conf = ::File.join(Chef::Config[:file_cache_path], "newrelic-prototype.ini")

execute "generate prototype newrelic ini" do
  command "newrelic-admin generate-config #{n["key"]} \"#{ini_conf}\""
  not_if "test -f \"#{ini_conf}\""
end

# TODO -- add log_dir directory creation to make sure they exist also
# TODO -- create the user?

directory n["dir"] do
  owner n["user"]
  group n["user"]
  mode "0774"
  recursive true
  action :create
end


###############################################################################
# build ini file for each app
###############################################################################
n["apps"].each do |app_name, _app_config|

  app_ini_file = ::File.join(n["dir"], "#{app_name}.ini")
  app_config = _app_config.to_hash
  if !app_config["newrelic"].has_key?("app_name")
    app_config["newrelic"]["app_name"] = app_name
  end
  app_config["newrelic"]["license_key"] = n["key"]

  cache_ini_file = ::File.join(Chef::Config[:file_cache_path], "#{app_name}.ini")
  ruby_block "configure #{app_name} newrelic" do
    block do

      # build a config file mapping we can manipulate
      conf_lines = []
      conf_lookup = {}
      conf_section = ""

      # TODO -- not good to re-parse this every iteration :(
      ::File.read(ini_conf).each_line.with_index do |conf_line, index|

        if m = conf_line.match(/^\[([^\]]+)\]/) # looking for sections
          if !conf_section.empty?
              conf_lookup[conf_section]["stop"] = index - 1
          end

          conf_section = m[1]
          conf_lookup[conf_section] = {
            "start" => index,
            "config" => {},
            "stop" => index
          }

        elsif conf_line.match(/^[^#\[]\S+/) # name = val
          conf_var, conf_val = conf_line.split(/\s*=\s*/, 2)
          conf_lookup[conf_section]["config"][conf_var] = index

        elsif conf_line.match(/^#\s*\S+\s*=/) # # name = val
          conf_var, conf_val = conf_line.sub(/^#\s*/, "").split(/\s*=\s*/, 2)
          conf_lookup[conf_section]["config"][conf_var] = index

        end

        conf_line.rstrip!
        conf_lines << conf_line

      end

      # actually plug the new configuration into the file
      app_config.each do |section, section_config|
        section_new_lines = ""
        section_config.each do |key, val|
          line = "#{key} = #{val}"
          if conf_lookup[section]["config"].has_key?(key)
            conf_lines[conf_lookup[section]["config"][key]] = line
          else
            section_new_lines += "#{line}\n"
          end
        end

        # append the new lines to the end of the section
        if !section_new_lines.empty?
          index = conf_lookup[section]["stop"]
          conf_lines[index] = section_new_lines + conf_lines[index] + "\n"
        end

      end

      # write the cache file out
      ::File.open(cache_ini_file, "w+") do |f|
        conf_lines.each do |conf_line|
          f.puts(conf_line)
        end
      end

    end
    notifies :create, "remote_file[#{app_ini_file}]", :immediately

  end

  remote_file app_ini_file do
    source "file://#{cache_ini_file}"
    mode "0660"
    user n["user"]
    group n["user"]
    action :nothing
    #notifies :restart, "service[#{name}]", :delayed
  end

end

