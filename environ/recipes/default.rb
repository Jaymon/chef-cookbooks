name = cookbook_name.to_s
n = node[name]

# first add all the files to the environment
fs = []
fs.concat(n["global"].fetch(:file, []))
fs.concat(n.fetch(:file, []))

fs.each do |file_name|

  env = environ file_name do
    value file_name
    action :file
  end

  n.fetch('notifies', []).each do |params|
    env.notifies(*params)
  end

end

# after files are added, then add the explicitely set variables (they have precedence)
d = {}
d.merge!(n["global"].fetch(:set, {}))
d.merge!(n.fetch(:set, {}))

d.each do |key, val|

  env = environ key do
    value val
    action :set
  end

  # set the notifies stuff to allow things to change based on changes to the environment
  n.fetch('notifies', []).each do |params|
    env.notifies(*params)
  end

end

