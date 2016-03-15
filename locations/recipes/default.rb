name = cookbook_name.to_s
n = node[name]

if n && n.has_key?('users') && !n['users'].empty?

  n['users'].each do |username, files|
    files.each do |dname, d|
      src_dir = ''
      src_file = d.fetch('src', '')
      dest_dir = ''
      dest_file = d['dest']
      pos = src_file =~ /\S+:\/\//
      if pos == nil
        if ::File.file?(src_file)
          dest_dir = ::File.dirname(dest_file)
          src_file = "file://#{src_file}"

        elsif ::File.directory?(src_file)
          src_dir = src_file
          src_file = ''
          dest_dir = dest_file
          dest_file = ''

        else
          dest_dir = dest_file
          #raise "no local source file found at location #{src_file}"

        end
      end

  #     p "dest_dir #{dest_dir}"
  #     p "src_dir #{src_dir}"
  #     p "src_file #{src_file}"
  #     p "dest_file #{dest_file}"

      if dest_dir != ''
        directory "#{dname}_dest_dir" do
          path dest_dir
          owner username
          group d.fetch('group', username)
          action :create
          recursive true
          #not_if { ::File.directory?(dest_dir) }
        end
      end

      if src_file != ''
        remote_file dname do
          path dest_file
          owner username
          group d.fetch('group', username)
          mode d.fetch('mode', nil)
          source src_file
          action d.fetch('action', :create)
        end

      elsif src_dir != ''
        remote_directory dname do
          path dest_dir
          owner username
          group d.fetch('group', username)
          mode d.fetch('mode', nil)
          source src_dir
          action d.fetch('action', :create)
          recursive true
        end
      end

    end
  end

end

