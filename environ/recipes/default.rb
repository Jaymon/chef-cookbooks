name = cookbook_name.to_s
n = node[name]


# create the directories we'll need later
n["dirs"].each do |k, d|
  directory d do
    mode "0755"
    recursive true
    action :create
  end
end


configuration_path = ::File.join(n["dirs"]["configuration"], n["basename"])
installation_path = ::File.join(n["dirs"]["installation"], n["basename"])
environ = ::EnvironHash.new(configuration_path, false)


# first add all the files to the environment
#fs = []
#fs.concat(n["global"].fetch(:file, []))
#fs.concat(n.fetch(:file, []))
fs = n.fetch(:file, [])

fs.each do |file_name|

  env = environ file_name do
    value file_name
    action :file
    environ environ
  end

  n.fetch('notifies', []).each do |params|
    env.notifies(*params)
  end

end


# after files are added, then add the explicitely set variables since they have precedence
# d = {}
# d.merge!(n["global"].fetch(:set, {}))
# d.merge!(n.fetch(:set, {}))
d = n.fetch(:set, {})

d.each do |key, val|

  env = environ key do
    value val
    action :set
    environ environ
  end

  # set the notifies stuff to allow things to change based on changes to the environment
  n.fetch('notifies', []).each do |params|
    env.notifies(*params)
  end

end


template "#{name} #{installation_path} installation" do
  path installation_path
  backup false
  owner "root"
  group "root"
  source "installation.erb"
  mode "0644"
  variables "path" => environ.file, "name" => name
end


