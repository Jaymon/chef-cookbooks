name = cookbook_name.to_s
n = node["docker-config"]


# installation directions comes from:
# https://docs.docker.com/engine/install/ubuntu/

###############################################################################
# Initial setup and pre-requisites
###############################################################################
# https://docs.chef.io/resources/package/
packages = [
  "docker.io",
  "docker-doc",
  "docker-compose",
  "docker-compose-v2",
  "podman-docker",
  "containerd",
  "runc",
]
packages.each do |pkg|
  package pkg do
    action :remove
  end
end


# needed to verify pgp key
package "gnupg"


# https://docs.chef.io/resources/apt_repository/
apt_repository name do
  uri "https://download.docker.com/#{node['os']}/#{node['platform']}/"
  components ["stable"]
  deb_src true
  key "https://download.docker.com/#{node['os']}/#{node['platform']}/gpg"
  keyserver false
  distribution node["os_release"]["version_codename"]
end


###############################################################################
# Installation
###############################################################################
packages = [
  "docker-ce",
  "docker-ce-cli",
  "containerd.io",
  "docker-buildx-plugin",
  "docker-compose-plugin",
]

if n.has_key?("version") && !n["version"].empty?
  packages[0] += "=#{n['version']}"
  packages[1] += "=#{n['version']}"

end

packages.each do |pkg|
  package pkg
end

# https://docs.chef.io/resources/service/
service name do
  service_name name
  action :start
  #restart_command "systemctl stop #{name}; systemctl start #{name}"
  restart_command "service #{name} stop; service #{name} start"
end

