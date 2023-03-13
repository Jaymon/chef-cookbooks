name = cookbook_name.to_s
n = node[name]

include_recipe "pyenv"

common_config = n.fetch("common", {})

n.fetch("environments", {}).each do |venv_name, venv_config|

  # unify the configuration for this environment
  config = {}
  config = ::Chef::Mixin::DeepMerge.merge(config, common_config)
  config = ::Chef::Mixin::DeepMerge.merge(config, venv_config)
  #p "========================================================================="
  #pp config
  #p "========================================================================="

  version = config["version"]
  username = config["user"]

  pyenv version do
    user username
    virtualenv venv_name
  end

  ["requirements", "dependencies", "packages"].each do |k|
    if config.has_key?(k)
      config[k].each do |package_name|

        recipe_names, package_names = PythonHelper.get_recipes_packages(name, node, package_name)

        #p "==================================================================="
        #pp recipe_names
        #pp package_names
        #p "==================================================================="

        recipe_names.each do |recipe_name, package_name|
          node.run_state[name] = {
            "package_name" => package_name,
            "version" => version,
            "username" => username,
            "virtualenv" => venv_name,
            "config" => config,
          }
          include_recipe "#{name}::#{recipe_name}"

        end

        package_names.each do |package_name|
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

include_recipe "#{name}::uwsgi"

