name = cookbook_name.to_s
n = node[name]

if !n['timezone'].empty?

  tz_file = ::File.join("", "usr", "share", "zoneinfo", n['timezone'])
  etc_dir = ::File.join("", "etc")
  localtime_file = ::File.join(etc_dir, "localtime")
  timezone_file = ::File.join(etc_dir, "timezone")

  # backup original files
  execute "mv #{localtime_file} #{localtime_file}.bak" do
    cwd etc_dir
    not_if "test -f #{localtime_file}.bak"
  end

  execute "mv #{timezone_file} #{timezone_file}.bak" do
    cwd etc_dir
    not_if "test -f #{timezone_file}.bak"
  end

  # now copy the timezone to the localtime
  execute "test -f #{tz_file}" do
    action :run
    notifies :run, "execute[cp_localtime]", :immediately
    notifies :run, "execute[echo_timezone]", :immediately
  end

  execute "cp_localtime" do
    command "cp #{tz_file} #{localtime_file}"
    action :nothing
  end

  execute "echo_timezone" do
    command "echo \"#{n['timezone']}\" > #{timezone_file}"
    action :nothing
  end

end
