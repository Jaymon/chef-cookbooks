name = cookbook_name.to_s
n = node[name]
keys_d = n[recipe_name.to_s]


extend ::Chef::Mixin::ShellOut
require 'digest'


# load up all the keys
authorized_keys = []
keys = keys_d.fetch("keys", [])
keys.each do |key_file|

  #authorized_keys << File.open(key_file, "r").read.strip
  if ::File.exists?(key_file)
    authorized_keys << File.open(key_file, "r").read

  else
    # if the key wasn't an actual file, assume it is just a key so let's validate it
    # http://unix.stackexchange.com/questions/82166/how-to-validate-an-ssh-public-key
    # http://stackoverflow.com/questions/2635360/ssh-keygen-accepting-stdin
    # http://serverfault.com/questions/453296/how-do-i-validate-a-rsa-ssh-public-key-file-id-rsa-pub
    # BAH! Sadly this doesn't work with the redirect
    # cmd = shell_out!("ssh-keygen -lf /dev/stdin <<< \"#{key_file}\"")

    # we dump the key to a file so we can validate it and make sure it is a valid key
    md5 = Digest::MD5.hexdigest key_file
    key_f = ::File.join(::Chef::Config[:file_cache_path], "#{md5}.pub")
    # if these don't fail then the key is valid
    cmd = shell_out!("echo \"#{key_file}\" > \"#{key_f}\"")
    cmd = shell_out!("ssh-keygen -lf \"#{key_f}\"")
    authorized_keys << key_file.strip
  end

end


if authorized_keys.length > 0

  users = keys_d.fetch("users", n.fetch("users", []))

  users.each do |username|

    home_d = get_homedir(username)
    if home_d.empty?
      ::Chef::Log.warn("[#{username}] has no home directory so authorized_keys cannot be set")
      next
    end

    ssh_dir = ::File.join(home_d, ".ssh")
    key_file = ::File.join(ssh_dir, 'authorized_keys')
    key_file_bak = "#{key_file}.bak"

    directory "#{username} #{recipe_name.to_s} #{ssh_dir}" do
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

