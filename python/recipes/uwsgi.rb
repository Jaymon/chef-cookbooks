##
# create python plugins for uwsgi
#
# I don't love this solution at all, it has high coupling to both the uwsgi cookbook
# because it currently needs to be run after the uwsgi cookbook and needs access to
# the uwsgi node configuration. It is also coupled to the pyenv cookbook (but this
# whole cookbook is) but it basically uses the actual paths to where pyenv installs
# python
##
name = cookbook_name.to_s
name_recipe = recipe_name.to_s
n = node[name]


common_config = n.fetch("common", {})

n.fetch("environments", {}).each do |venv_name, venv_config|

  # unify the configuration for this environment
  config = {}
  config.merge!(common_config)
  config.merge!(venv_config)

  if config.has_key?("uwsgi")
    # get the path of uwsgi, this can be done 1 of 2 ways:
    # 1. get it from node["uwsgi"]["dirs"]["installation"]
    # 2. dirname $(readlink $(which uwsgi)) in a block since it needs to run during run phase
    #    https://stackoverflow.com/a/29789399/5006
    uwsgi_dir = node.fetch("uwsgi", {}).fetch("dirs", {})["installation"]
    plugin_name = venv_config["uwsgi"]

    version = config["version"]
    username = config["user"]

    uwsgi_plugin_name = "#{plugin_name}_plugin.so"

    bash "python uwsgi build plugin #{plugin_name}" do
      code <<~EOH
        #set -x

        homedir=$(grep -e "^#{username}:" /etc/passwd | cut -d":" -f6)
        export PYTHON=${homedir}/.pyenv/versions/#{version}/bin/python

        #. /etc/profile.d/pyenv.sh
        #pyenv shell #{version}
        #export PYTHON=python

        ./uwsgi --build-plugin "plugins/python #{plugin_name}"

        #set +x
        EOH
      #user username
      cwd uwsgi_dir
      not_if { ::File.exist?(::File.join(uwsgi_dir, uwsgi_plugin_name)) }
    end

  end

end

