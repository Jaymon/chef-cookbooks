##
# Install ZeroMQ
##

name = cookbook_name.to_s
#name = "zeromq"
n = node[name]
src_dir = Chef::Config[:file_cache_path]
src_basename = "zeromq-#{n["version"]}"
src_tarfile = "#{src_basename}.tar.gz"
src_filepath = ::File.join(src_dir, src_tarfile)
src_extract_dir = ::File.join(src_dir, src_basename)

# prerequisites
["make", "g++"].each do |package_name|
  package package_name do
    action :install
  end
end

remote_file src_filepath do
  source "http://download.zeromq.org/#{src_tarfile}"
  action :create_if_missing
end

bash "extract_zeromq" do
  user "root"
  cwd src_dir
  code <<-EOH
  mkdir -p "#{src_extract_dir}"
  tar -xzf "#{src_tarfile}" -C "#{src_extract_dir}"
  EOH
  #not_if { ::File.exists?(src_extract_dir) }
  not_if "test -d #{src_extract_dir}"
end

bash "install_zeromq" do
  user "root"
  cwd src_extract_dir
  code <<-EOH
  cd $(find "#{src_extract_dir}" -maxdepth 1 -mindepth 1 -type d )
  ./configure
  make
  make install
  EOH
  #not_if { ::File.exists?("/usr/local/include/zmq.h") }
  not_if "test -f /usr/local/include/zmq.h"
end
