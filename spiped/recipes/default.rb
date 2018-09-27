require 'tmpdir'
require 'digest'

name = cookbook_name.to_s
n = node[name]
u = n['user']


###############################################################################
# pre-requisites
###############################################################################

# create the user that will manage redis
group u do
  not_if "id -u #{u}"
end

user name do
  username u
  system true
  gid u
  shell "/bin/false"
  not_if "id -u #{u}"
end

["build-essential", "libssl-dev"].each do |p|
  package p
end


###############################################################################
# Installation
###############################################################################
version = n["version"]
tempdir = ::Dir.tmpdir
basename = "spiped-#{version}"
zip_filename = "#{basename}.tgz"
zip_filepath = ::File.join(::Chef::Config[:file_cache_path], zip_filename)
zip_url = "http://www.tarsnap.com/spiped/#{zip_filename}"
unzip_filepath = ::File.join(tempdir, basename)

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
# create directories and put things in the right place
###############################################################################
dirs = {
  'etc' => [::File.join("", "etc", name), u, u],
}

dirs.each do |k, d|
  directory d[0] do
    owner d[1]
    group d[2]
    mode "0755"
    recursive true
    action :create
  end
end


###############################################################################
# Upstart
###############################################################################
services = []
pid_dir = ::File.join("", "var", "run", "spiped")
default_vals = n.fetch('defaults', {})

n["pipes"].each do |pipe_type, pipes|

  pipes.each do |pname, _vals|

    # combine defaults with specific vals
    vals = default_vals.merge(_vals)

    exec = ::File.join("", "usr", "local", "bin", "spiped")
    pid_filepath = ::File.join(pid_dir, pname)
    key_dest_filepath = ::File.join(dirs['etc'][0], "#{pname}.key")

    if ::File.file?(vals['key'])
        key_source_filepath = vals['key']

    else
        md5 = ::Digest::MD5.new
        md5.update(vals['key'])
        key_source_filepath = ::File.join(tempdir, "#{md5.hexdigest}.key")
        file key_source_filepath do
          content vals['key']
          mode "0644"
        end

    end

    # we need to move the key to a final resting place on the system, this is to
    # address a problem mainly with vagrant boxes not having access to shared
    # folders when a box is brought back up, causing the spiped daemons to die
    remote_file key_dest_filepath do
      source "file://#{key_source_filepath}"
      mode "0644"
      notifies :restart, "service[#{pname}]", :delayed
    end

    args = pipe_type.to_s() == "client" ? "-e" : "-d"

    host, ip = vals["source"].split(":", 2)
    host.tr!("][", "")
    args += " -s [#{host}]:#{ip}"

    host, ip = vals["target"].split(":", 2)
    host.tr!("][", "")
    args += " -t [#{host}]:#{ip}"

    args += " -k \"#{key_dest_filepath}\""
    args += " -p \"#{pid_filepath}\""

    if vals.has_key?("connections")
      args += " -n \"#{vals['connections']}\""
    end

    if vals.has_key?("timeout")
      args += " -o \"#{vals['timeout']}\""
    end

    template ::File.join("etc", "init", "#{pname}.conf") do
      source "upstart.conf.erb"
      mode "0644"
      variables(
        "exec" => exec,
        "username" => u,
        "usergroup" => u,
        "args" => args,
        'pidfile' => pid_filepath,
        'run_dir' => pid_dir
      )
      notifies :stop, "service[#{pname}]", :immediately
      notifies :start, "service[#{pname}]", :immediately
    end

    service pname do
      provider Chef::Provider::Service::Upstart
      action :start
      supports :start => true, :stop => true, :status => true, :restart => true
      #supports :start => true, :stop => true, :restart => true
    end

    services << pname

  end

end

# if we've registered some services, let's create a catch all service that can
# start and stop all services registered on this box
if !services.empty?

  service name do
    service_name name
    provider Chef::Provider::Service::Upstart
    action :nothing
    supports :status => true, :start => true, :stop => true, :restart => true
  end

  template ::File.join("", "etc", "init", "#{name}.conf") do
    source "upstarts.conf.erb"
    mode "0644"
    variables({"services" => services})
    notifies :stop, "service[#{name}]", :delayed
    notifies :start, "service[#{name}]", :delayed
  end

end


