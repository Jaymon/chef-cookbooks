name = cookbook_name.to_s
n = node[name]

include_recipe "pip"

n.each do |key, options|

  u = options['user']
  d = options['dir']
  pip_file = ::File.join(d, "requirements.txt")

  directory d do
    owner u
    group u
    mode "0755"
    recursive true
    action :create
  end

  if options.has_key?('repo') and !options['repo'].empty?

    execute "find #{d} -name '*.pyc' -delete" do
    end

    # move back onto the deploy branch on every run
    # I have a tendency to test some code by switching branches and then just pulling
    # directly, but after a new chef run, chef git resource will just reset hard 
    # whatever the current branch is instead of the deploy branch it originally
    # created, this will move back to that deploy branch so I know things have been
    # reset
    execute "git checkout deploy" do
      cwd d
      only_if "test -d .git", :cwd => d
      not_if "git status | grep \"On branch deploy\"", :cwd => d
    end

    r = git key do
      destination d
      repository options["repo"]
      user u
      group u
      revision options["branch"]
      action :sync
      depth 2
    end

    if options.has_key?("notifies")
      options['notifies'].each do |params|
        r.notifies(*params)
      end
    end

  end

  # we are going to be a little trixy here, what we are going to do is have chef
  # manage a seninal requirements.txt file, if that file has changed it will kick
  # off running pip
  pip_sentinal_file = ::File.join(Chef::Config[:file_cache_path], "#{key}-requirements-sentinal.text")
  remote_file pip_sentinal_file do
    backup false
    source "file://#{pip_file}"
    notifies :install, "pip[#{pip_file}]", :immediately
    only_if { ::File.exists?(pip_file) }
  end

  pip pip_file do
    action :nothing
  end

end

