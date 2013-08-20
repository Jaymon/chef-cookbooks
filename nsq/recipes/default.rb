name = cookbook_name.to_s
n = node[name]
u = n['user']
src_dir = Chef::Config[:file_cache_path]
src_basename = "nsq-#{n["version"]}"
src_tarfile = "#{src_basename}.linux-amd64.go1.1.1.tar.gz"
src_filepath = ::File.join(src_dir, src_tarfile)
src_extract_dir = ::File.join(src_dir, src_basename)

# create the user and group that nsq will run under
group u do
  system true
  append true
end

user u do
  system true
  gid u
  shell "/bin/false"
end

remote_file src_filepath do
  source "https://s3.amazonaws.com/bitly-downloads/nsq/#{src_tarfile}"
  action :create_if_missing
end

bash "extract_nsq" do
  user "root"
  cwd src_dir
  code <<-EOH
  mkdir -p "#{src_extract_dir}"
  tar -xzf "#{src_tarfile}" -C "#{src_extract_dir}"
  real_extract_dir=$(find "#{src_extract_dir}" -maxdepth 1 -mindepth 1 -type d)
  mv "$real_extract_dir"/* "#{src_extract_dir}"/
  rmdir "$real_extract_dir"
  EOH
  not_if "test -d #{src_extract_dir}"
end

directory n['bin_dir'] do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

bash "move_nsq_executables" do
  user "root"
  cwd src_extract_dir
  code <<-EOH
  # set -x
  cd bin
  for f in *; do
    if [[ -f $f ]]; then
      bin_f="#{n['bin_dir']}"/$f
      mv -u "$f" "$bin_f"
      chmod 755 "$bin_f"
    fi
  done
  EOH
end

directory n['share_dir'] do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

bash "move_nsq_share" do
  user "root"
  group "root"
  code <<-EOH
    mv -u share/* \"#{n['share_dir']}\"
  EOH
  cwd src_extract_dir
end

directory n['data_dir'] do
  owner u
  group u
  mode "0755"
  recursive true
  action :create
end

n['services'].each do |name, options|

  if !options.empty?

    template ::File.join("", "etc", "init", "#{name}.conf") do
      source "service.conf.erb"
      owner "root"
      group "root"
      mode "0655"
      variables("command" => options['command'], "user" => u)
      notifies :restart, "service[#{name}]", :delayed
    end

    service name do
      provider Chef::Provider::Service::Upstart
      service_name name
      action options['action']
      supports :start => true, :stop => true, :status => true, :restart => true
    end

  end

end

