# http://askubuntu.com/questions/162229/how-do-i-increase-the-open-files-limit-for-a-non-root-user
name = cookbook_name.to_s
n = node[name]

if n.has_key?("fd")
  fd_source = ::File.join(::Chef::Config[:file_cache_path], "fd-limits.conf")
  fd_dest = ::File.join("", "etc", "security", "limits.d", "fd-limits.conf")

  ::File.open(fd_source, "w+") do |f|
    n['fd'].each do |user, fd_limit|
      f.puts("#{user} soft nofile #{fd_limit}")
      f.puts("#{user} hard nofile #{fd_limit}")
    end
  end

  remote_file fd_dest do
    source "file://#{fd_source}"
    mode "0644"
  end

  ['common-session'].each do |filename|
    filepath_source = ::File.join(::Chef::Config[:file_cache_path], filename)
    filepath_dest = ::File.join("", "etc", "pam.d", filename)

    conf_lines = []
    found_index = -1
    ::File.read(filepath_dest).each_line.with_index do |conf_line, index|
      conf_line.rstrip!
      conf_lines << conf_line
      if conf_line =~ /^session\s+required\s+pam_limits\.so/i
        found_index = index
        break
      end
    end

    if found_index == -1
      conf_lines << "session required pam_limits.so"

      ::File.open(filepath_source, "w+") do |f|
        f.puts(conf_lines)
      end

      remote_file filepath_dest do
        source "file://#{filepath_source}"
        mode "0644"
      end

    end

  end

end

