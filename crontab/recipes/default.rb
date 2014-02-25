name = cookbook_name.to_s
n = node[name]

# TODO -- completely clear the crontab file? Otherwise what happens if we remove a cronjob?
# looks like you could actually go through the crontab and just remove the ones that chef
# manages, and leave any manual ones, which might be the best way to do it


# add the environment to the beginning of the command
cron_env = ""
if n.has_key?('env') and !n['env'].empty?
  e = n['env']
  if ::File.exists?(e)
    if ::File.directory?(e)
      cron_env += "for f in #{::File.join(e, "*")}; do . $f; done;"

    else
      cron_env += ". $f;"

    end
  else
    ::Chef::Application.fatal!("#{e} is NOT a file or directory")
  end

end

cron_logdir = n.fetch('logdir', '')

n['users'].each do |username, cron_jobs|

  cron_jobs.each do |cron_name, options|
    cron_cmd = cron_env
    p options

    # change to the right directory
    if options.has_key?('dir') and !options['dir'].empty?
      d = options['dir']
      if ::File.directory?(d)
        cron_cmd += "cd #{d};"

      else
        ::Chef::Application.fatal!("#{d} is NOT a valid directory")

      end
    end

    cron_cmd += options['command']

    if cron_logdir

      cron_user_logdir = ::File.join(cron_logdir, username)

      directory cron_user_logdir do
        owner username
        group username
        mode '0777'
        recursive true
      end

      cron_cmd += " >> #{::File.join(cron_user_logdir, cron_name)}.log 2>&1"

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
end
