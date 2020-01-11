name = cookbook_name.to_s
n = node[name]


include_recipe "pyenv"

common_config = n.fetch("common", {})

n.fetch("environments", {}).each do |venv_name, venv_config|

  # unify the configuration for this environment
  config = {}
  config.merge!(common_config)
  config.merge!(venv_config)

  version = config["version"]
  username = config["user"]

  pyenv version do
    user username
    virtualenv venv_name
  end

  ["requirements", "dependencies", "packages"].each do |k|
    if config.has_key?(k)
      config[k].each do |package_name|

        recipe_name = "package_#{package_name.downcase.match('^[a-z][a-z0-9_]*')[0]}"
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

end

