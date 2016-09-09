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
    execute "git #{d} move to deploy branch" do
      command "git checkout deploy"
      cwd d
      only_if "test -d .git", :cwd => d
      not_if "git status | grep \"On branch deploy\"", :cwd => d
    end

    # 9-9-2016, I borked the checkout command and it failed silently because git
    # 1.9.1 (Ubuntu 14.04) returns a 0 return code, even if the command doesn't
    # do anything, this block will fail though and stop the chef provision if we
    # haven't really moved to the right branch
    execute "git #{d} verify on deploy branch" do
      command "git status | grep \"On branch deploy\""
      cwd d
      only_if "test -d .git", :cwd => d
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

  #############################################################################
  # this is such a hack I'm not even sure I believe it works or that I did it.
  # Basically this creates a fake resource "pip sentinal" that doesn't have a destination
  # path, then in the ruby block "pip run needed?" it figures out the path, pulls out
  # and updates the "pip sentinal" resource and then runs pip on it. I think this
  # might be better off as just a bash script that does pretty much the same thing
  # since this just feels super hacky
  #
  # I think the idea of this is to only run pip if something has changed in the pip file
  # and you can't use the git history because of how chef pulls the code
  #############################################################################
  pip_file = ::File.join(d, "requirements.txt")

  remote_file "pip sentinal #{d}" do
    source "file://#{pip_file}"
    backup false
    action :nothing
  end

  ruby_block "pip run needed? #{d}" do
    block do
      if ::File.exists?(pip_file)
        pip_sentinal_file = ::File.join(::Chef::Config[:file_cache_path], "#{key}-#{::Digest::MD5.file(pip_file).hexdigest}.requirements.txt")

        if !::File.exists?(pip_sentinal_file)

          # http://sysadvent.blogspot.com/2012/12/day-24-twelve-things-you-didnt-know.html
          res2 = resources("remote_file[pip sentinal #{d}]")
          res2.path pip_sentinal_file
          res2.action :create

          res = ::Chef::Resource::Pip.new(pip_file, run_context)
          #res.not_if { ::File.exists?(pip_sentinal_file) }
          res.notifies_immediately :create, "remote_file[pip sentinal #{d}]"
          res.run_action(:install)

        end

      end
    end
  end

end

