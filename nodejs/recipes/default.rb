name = cookbook_name.to_s
n = node[name]


::Chef::Recipe.send(:include, ::Chef::Mixin::ShellOut)


package "xz-utils" do
  options "--no-install-recommends"
end


cmd = shell_out!("getconf LONG_BIT")
bits = cmd.stdout.strip

if bits.to_s =~ /64/
  nodejs_f = "node-v#{n["version"]}-linux-x64.tar.xz"
else
  nodejs_f = "node-v#{n["version"]}-linux-x86.tar.xz"
end

nodejs_url = "https://nodejs.org/dist/v#{n["version"]}/#{nodejs_f}"

remote_file ::File.join(::Chef::Config[:file_cache_path], nodejs_f) do
  source nodejs_url
  action :create
end


not_cmd = "node --version | grep \"#{n["version"]}\""

directory n["prefix"] do
  mode "0755"
  recursive true
  action :create
  not_if not_cmd
end

execute "tar -C #{n["prefix"]} --strip-components 1 -xJf #{nodejs_f}" do
  cwd ::Chef::Config[:file_cache_path]
  not_if not_cmd
end

