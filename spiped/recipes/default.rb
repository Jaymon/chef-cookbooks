require 'tmpdir'

name = cookbook_name.to_s
n = node[name]

version = n["version"]
tempdir = ::Dir.tmpdir
basename = "spiped-#{version}"
zip_filename = "#{basename}.tgz"
zip_filepath = ::File.join(::Chef::Config[:file_cache_path], zip_filename)
zip_url = "http://www.tarsnap.com/spiped/#{zip_filename}"
unzip_filepath = ::File.join(tempdir, basename)
pid_dir = ::File.join("", "var", "run", "spiped")


###############################################################################
# pre-requisites
###############################################################################
["build-essential", "libssl-dev"].each do |p|
  package p
end

###############################################################################
# Installation
###############################################################################
remote_file zip_filepath do
  source zip_url
  action :create_if_missing
  notifies :run, "execute[untar #{zip_filepath}]", :immediately
end

execute "untar #{zip_filepath}" do
  command "tar -xf \"#{zip_filepath}\" -C /tmp"
  notifies :run, "execute[install #{unzip_filepath}]", :immediately
end

execute "install #{unzip_filepath}" do
  command "make install"
  cwd unzip_filepath
end

###############################################################################
# Upstart
###############################################################################
n["pipes"].each do |pipe_type, pipes|
  pipes.each do |name, vals|

    exec = ::File.join("", "usr", "local", "bin", "spiped")
    pid_filepath = ::File.join(pid_dir, name)

    args = pipe_type.to_s() == "client" ? "-e" : "-d"

    host, ip = vals["source"].split(":", 2)
    host.tr!("][", "")
    args += " -s [#{host}]:#{ip}"

    host, ip = vals["target"].split(":", 2)
    host.tr!("][", "")
    args += " -t [#{host}]:#{ip}"

    args += " -k \"#{vals["key"]}\""
    args += " -p \"#{pid_filepath}\""

    template ::File.join("etc", "init", "#{name}.conf") do
      source "upstart.conf.erb"
      mode "0644"
      variables(
        "exec" => exec,
        "username" => vals.fetch("user", ""),
        "usergroup" => vals.fetch("user", ""),
        "args" => args,
        'pidfile' => pid_filepath,
        'run_dir' => pid_dir
      )
      notifies :stop, "service[#{name}]", :delayed
      notifies :start, "service[#{name}]", :delayed
    end

    service name do
      provider Chef::Provider::Service::Upstart
      action :start
      supports :start => true, :stop => true, :status => true, :restart => true
    end

  end
end

