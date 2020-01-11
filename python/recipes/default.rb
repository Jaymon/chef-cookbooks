name = cookbook_name.to_s
n = node[name]


#require 'pry'
#binding.pry

require "pp"
#print("=======================================================================")
#PP.pp(node["@cookbook_collection"])
#PP.pp(::Chef::RunContext)

# TODO -- this does it, I can use this to figure out if I have a recipe for a given
# dependency and then I can run that recipe to install prereqs, then I can call pip
# here, I will need to check for version strings, so basically just get the first
# ^[a-zA-Z][a-zA-Z0-9_]+ and use that to check for a recipe, then go ahead and run
# the recipe
#PP.pp(node.run_context.cookbook_collection[name])
# via: https://discourse.chef.io/t/getting-cookbookversion-at-runtime/5250/3
# https://discourse.chef.io/t/getting-cookbookversion-at-runtime/5250/2
#PP.pp(cookbook_collection)

include_recipe "pyenv"

# print("=====================================================================")
# PP.pp(n)
# print("=====================================================================")

common_config = n.fetch("common", {})

n.fetch("environments", {}).each do |venv_name, venv_config|

  # unify the configuration for this environment
  config = {}
  config.merge!(common_config)
  config.merge!(venv_config)

  version = config["version"]
  username = config["user"]

#   print("=====================================================================")
#   PP.pp(venv_name)
#   PP.pp(venv_config)

  pyenv version do
    user username
    virtualenv venv_name
  end

  ["requirements", "dependencies", "packages"].each do |k|
    if config.has_key?(k)
      config[k].each do |package_name|

        recipe_name = "package_#{package_name.downcase}"
        # via: https://discourse.chef.io/t/getting-cookbookversion-at-runtime/5250/3
        # https://discourse.chef.io/t/getting-cookbookversion-at-runtime/5250/2
        if node.run_context.cookbook_collection[name].recipe_filenames_by_name.has_key?(recipe_name)
          node.run_state[name] = {
            "package_name" => package_name,
            "version" => version,
            "username" => username,
            "virtualenv" => venv_name,
            "config" => config,
          }
          include_recipe "#{name}::#{recipe_name}"

        else
          pyenv_package package_name do
            user username
            version version
            virtualenv venv_name
          end

        end

      end
    end
  end


#   bash "#{name} #{version} #{username} install virtualenv" do
#     code <<-EOH
#       #set -x
# 
#       . /etc/profile.d/pyenv.sh
# 
#       #export PATH=/home/vagrant/.pyenv/shims:$PATH
#       #/opt/pyenv/bin/pyenv rehash
#       #/opt/pyenv/bin/pyenv versions
# 
# 
# 
#       #HOME=/home/vagrant
#       #export PATH=/home/vagrant/.pyenv/shims:$PATH
#       #. /etc/profile.d/pyenv.sh
#       #/opt/pyenv/bin/pyenv versions
#       #eval "$(/opt/pyenv/bin/pyenv init -)"
#       
#       /opt/pyenv/bin/pyenv versions
#       echo "==================================================================="
#       env
#       echo "==================================================================="
#       whoami
# 
#       #. /etc/profile.d/pyenv.sh
#       pyenv shell #{version}
#       pip install virtualenv
#       #set +x
#       EOH
#     user username
#     group username
#   end



#   execute "#{name} #{config["version"]} install virtualenv" do
#     command ". /etc/profile.d/pyenv.sh; pyenv shell #{config["version"]}; pip install virtualenv"
#     user config["user"]
#   end

end

