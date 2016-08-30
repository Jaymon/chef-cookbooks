name = cookbook_name.to_s
n = node[name][recipe_name.to_s]

# load up all the keys
authorized_keys = []
n.each do |key_file|

  authorized_keys << File.open(key_file, "r").read.strip
#   if ::File.exists?(key_file)
#     authorized_keys << File.open(key_file, "r").read
#   end

end

if authorized_keys.length > 0

  # we cheat, and get all the usernames by using their home folders
  dirs = ::Dir.glob(::File.join(::File::SEPARATOR, 'home', '*'))
  dirs.each do |d|

    username = ::File.basename(d)
    ssh_dir = ::File.join(d, ".ssh")
    key_file = ::File.join(ssh_dir, 'authorized_keys')
    key_file_bak = "#{key_file}.bak"

    directory "#{recipe_name.to_s} #{username} #{ssh_dir}" do
      path ssh_dir
      owner username
      group username
      mode "0700"
      action :create
    end

    # backup the original keys, create a blank bak file if there are none
    execute "mv #{key_file} #{key_file_bak}" do
      cwd ssh_dir
      user username
      group username
      not_if "test -f #{key_file_bak}"
      only_if "test -f #{key_file}"
    end

    file key_file_bak do
      content ""
      owner username
      group username
      mode "0600"
      not_if "test -f #{key_file_bak}"
    end


    # http://stackoverflow.com/questions/15292579/
    authorized_keys << "" # we want a newline at the end
    file key_file do
      content authorized_keys.join("\n")
      owner username
      group username
      mode "0600"
    end

    # append the original keys to the file
    execute "cat #{key_file_bak} >> #{key_file}" do
      user username
      group username
    end

  end

end

