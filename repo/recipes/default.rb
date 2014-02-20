name = cookbook_name.to_s
n = node[name]

include_recipe "pip"

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

    git key do
      destination d
      repository options["repo"]
      user u
      group u
      revision options["branch"]
      action :sync
      depth 2
    end

  end

  pip_file = ::File.join(d, "requirements.txt")
  pip pip_file do
    action :install
    only_if { ::File.exists?(pip_file) }
  end

end

