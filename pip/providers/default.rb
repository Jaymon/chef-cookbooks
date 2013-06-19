# http://docs.opscode.com/chef/lwrps_custom.html

def whyrun_supported?
  true
end

action :install do
  p = new_resource.package_name
  pip_cmd = "pip install"
  tmp = Chef::Config[:file_cache_path]

  if ::File.exists?(p) # file? That means it is a requirements file created from pip freeze
    pip_cmd += " -r #{p}"
  
  elsif p.match(/(?:git|\S+\+\S+):\/\/\S+/i) # repository url: git:// or repo+http://
  
    # the -e tells pip to keep the code around, we don't care about keeping it around and
    # want the code to be in dist-packages:
    # http://stackoverflow.com/questions/9402035/installing-python-package-from-github-using-pip
    # pip_cmd = p.match("-e") ? "pip install #{p}" : "pip install -e #{p}"
    pip_cmd += " #{p}"

  elsif p.match(/\S+:\/\/\S+/) # url? an archive that contains a setup.py file
    pip_cmd += " #{p}"

  else
    pip_cmd += " #{p}"

  end
  
  converge_by("Run #{pip_cmd}") do
    execute pip_cmd do
      cwd tmp
      user new_resource.user
      group new_resource.group
      action :run
      ignore_failure false
    end
  end

end

action :upgrade do
  p = new_resource.package_name
  pip_cmd = "pip install --upgrade"
  tmp = Chef::Config[:file_cache_path]

  if ::File.exists?(p) # file? That means it is a requirements file created from pip freeze
    pip_cmd += " -r #{p}"
  
  else
    pip_cmd += " #{p}"

  end
  
  converge_by("Run #{pip_cmd}") do
    execute pip_cmd do
      cwd tmp
      user new_resource.user
      group new_resource.group
      action :run
      ignore_failure false
    end
  end

end

