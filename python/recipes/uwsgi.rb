##
# create python plugins for uwsgi
#
# I don't love this solution at all, it has high coupling to both the uwsgi cookbook
# because it currently needs to be run after the uwsgi cookbook and accesses
# the uwsgi node configuration. It is also coupled to the pyenv cookbook (but this
# whole cookbook is) but it basically uses the actual paths to where pyenv installs
# python
##
name = cookbook_name.to_s
name_recipe = recipe_name.to_s
n = node[name]

::Chef::Recipe.send(:include, ::Chef::Mixin::ShellOut)

common_config = n.fetch("common", {})

n.fetch("environments", {}).each do |venv_name, venv_config|

  # unify the configuration for this environment
  config = {}
  config.merge!(common_config)
  config.merge!(venv_config)

  if config.has_key?("uwsgi")

    # get the path of uwsgi, this can be done in several ways
    # 1. get it from node["uwsgi"]["dirs"]["installation"]
    # 2. see if it is installed already and get the value using a mix of shell and ruby code
    # 3. `dirname $(readlink $(which uwsgi))` in a block since it needs to run during run phase
    #    https://stackoverflow.com/a/29789399/5006 basically we are going to do 2 again
    #    but this time in a block with the idea it got installed between compile and execute
    #    stages
    uwsgi_dir = node.fetch("uwsgi", {}).fetch("dirs", {})["installation"]
    if !uwsgi_dir
      ruby_block "#{name}_find_uwsgi_dir" do
        block do
          cmd = shell_out!("which uwsgi")
          uwsgi_path = cmd.stdout.strip
          if uwsgi_path
            uwsgi_dir = ::File.dirname(::File.realpath(uwsgi_path))
          else
            ::Chef::Application.fatal!('Could not find uWSGI installation directory')
          end

        end
      end
    end


    # original code that works but I think the above is more concise and works the same
#     if !uwsgi_dir
#       cmd = shell_out!("which uwsgi", { :returns => [0,1] })
#       uwsgi_path = cmd.stdout.strip
#       if uwsgi_path
#         uwsgi_dir = ::File.dirname(::File.realpath(uwsgi_path))
# 
#       else
# 
#         ruby_block "#{name}_find_uwsgi_dir" do
#           block do
#             cmd = shell_out!("which uwsgi")
#             uwsgi_path = cmd.stdout.strip
#             if uwsgi_path
#               uwsgi_dir = ::File.dirname(::File.realpath(uwsgi_path))
#             else
#               ::Chef::Application.fatal!('Could not find uWSGI installation directory')
#             end
# 
#           end
#         end
# 
#       end
#     end

    version = config["version"]
    username = config["user"]

    config["uwsgi"].each do |plugin_name, plugin_builder|

      uwsgi_plugin_name = "#{plugin_name}_plugin.so"

      bash "python uwsgi build plugin #{plugin_name} using #{plugin_builder}" do
        code <<~EOH
          #set -x

          homedir=$(grep -e "^#{username}:" /etc/passwd | cut -d":" -f6)
          export PYTHON=${homedir}/.pyenv/versions/#{version}/bin/python

          #. /etc/profile.d/pyenv.sh
          #pyenv shell #{version}
          #export PYTHON=python

          ./uwsgi --build-plugin "plugins/#{plugin_builder} #{plugin_name}"

          #set +x
          EOH
        #user username
        cwd uwsgi_dir
        not_if { ::File.exist?(::File.join(uwsgi_dir, uwsgi_plugin_name)) }
      end

    end

  end

end

