require 'digest/md5'

name = cookbook_name.to_s
n = node[name]


n.each do |key, options|

  u = options['user']
  d = options['dir']

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

  pip_file = ::File.join(d, "requirements.txt")

  remote_file "pip sentinal" do
    source "file://#{pip_file}"
    backup false
    action :nothing
  end

  ruby_block "pip run needed?" do
    block do
      if ::File.exists?(pip_file)
        # we are going to be a little trixy here, what we are going to do is have chef
        # manage a seninal requirements.txt file, if that file has changed it will kick
        # off running pip
        pip_sentinal_file = ::File.join(::Chef::Config[:file_cache_path], "#{key}-#{::Digest::MD5.file(pip_file).hexdigest}.requirements.txt")

        if !::File.exists?(pip_sentinal_file)

          # http://sysadvent.blogspot.com/2012/12/day-24-twelve-things-you-didnt-know.html
          res2 = resources("remote_file[pip sentinal]")
          res2.path pip_sentinal_file
          res2.action :create

          res = ::Chef::Resource::Pip.new(pip_file, run_context)
          res.not_if { ::File.exists?(pip_sentinal_file) }
          res.notifies_immediately :create, "remote_file[pip sentinal]"
          res.run_action(:install)

          p "========================================================================="
          p "========================================================================="
          p "========================================================================="
          p "========================================================================="
          p "========================================================================="
          #pp res
          p "========================================================================="
          p "========================================================================="
          p "========================================================================="
          p "========================================================================="
          p "========================================================================="

#           res2 = ::Chef::Resource::RemoteFile.new(pip_sentinal_file, run_context)
#           res2.backup false
#           res2.source "file://#{pip_file}"
#           res2.run_action(:create)
        end

      end
    end
  end

end

