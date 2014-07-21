require 'set'

name = cookbook_name.to_s
n = node[name]

# add the environment to the beginning of the command
cron_env = ""
if n.has_key?('env') and !n['env'].empty?
  e = n['env']
  if ::File.directory?(e)
    cron_env += "for f in #{::File.join(e, "*")}; do . $f; done;"

  else
    cron_env += ". $f;"
  end
end

cron_logdir = n.fetch('logdir', '')

n['users'].each do |username, cron_jobs|

  existing_cron_jobs = Set.new
  crontab = %x(sudo -u #{username} crontab -l)
  crontab.each_line do |line|
    m = /^#\s+Chef\s+Name:\s+(\S+)/i.match(line)
    if m
      existing_cron_jobs.add(m[1])
    end
  end

  cron_jobs.each do |cron_name, options|
    cron_cmd = cron_env
    existing_cron_jobs.delete(cron_name)

    # change to the right directory
    if options.has_key?('dir') and !options['dir'].empty?
      d = options['dir']
      cron_cmd += "cd #{d};"
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

  # remove any remaining cron jobs because they are no longer active
  existing_cron_jobs.each do |cron_name|
    cron cron_name do
      action :delete
      user username
    end
  end

end
