# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/
module Ssh
  module Helper

    include ::Chef::Mixin::ShellOut

    #root_shadow=$(grep -e "^root:" /etc/shadow)
    #root_orig_passwd_hash=$(echo $root_shadow | cut -d: -f2)

    def get_homedir(username)
      cmd = shell_out!("grep -e \"^#{username}:\" /etc/passwd | cut -d\":\" -f6")
      return cmd.stdout.strip
    end

#     def has_bacon?
#       #cmd = shell_out!("getent passwd bacon", {:returns => [0,2]})
#       #cmd.stderr.empty? && (cmd.stdout =~ /^bacon/)
#     end
  end
end

::Chef::Recipe.send(:include, Ssh::Helper)
#::Chef::Resource::User.send(:include, Ssh::Helper)
