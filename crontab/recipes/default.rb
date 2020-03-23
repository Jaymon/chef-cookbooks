name = cookbook_name.to_s
n = node[name]

users = n.fetch('users', n.fetch('usernames', []))

if users.empty?

  # https://docs.chef.io/resource_log.html
  ::Chef::Log.warn("#{name} recipe specified but not configured for any users")
  return

end


directory "#{name} #{n["dirs"]["log"]}" do
  path n["dirs"]["log"]
  mode '0777'
  recursive true
end


users.each do |username, cron_jobs|
  existing_cron_jobs = Crontab.get_existing_cronjobs(username)

  cron_jobs.each do |cron_name, options|

    existing_cron_jobs.delete(cron_name)
    config = Crontab.get_config(cron_name, options, n)

    cron_cmd = Crontab.get_environ(config)

    # change to the right directory
    if config.has_key?('chdir') and !config['chdir'].empty?
      cron_cmd += "cd #{config['chdir']};"
    end

    cron_cmd += config['command']

    cron_logfile = Crontab.get_logfile(cron_name, username, config, n)
    if !cron_logfile.empty?
      cron_cmd += " >> #{cron_logfile} 2>&1"
    end

    minute, hour, day_of_month, month, day_of_week = options['schedule'].split(%r{\s+}, 5)

    cron cron_name do
      action :create
      minute minute
      hour hour
      day = day_of_month
      month month
      weekday day_of_week
      user username
      command cron_cmd
    end

  end

  # remove any remaining cron jobs because they are no longer active
  existing_cron_jobs.each do |cron_name|
    cron cron_name do
      action :delete
      user username
    end
  end

end

