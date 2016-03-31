require "pathname"

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

        #p "dest_dir #{dest_dir}"
        #p "src_dir #{src_dir}"

        groupname = d.fetch('group', username)

        root_path = Pathname.new(src_dir)
        root_path.find do |path|
          unless path == root_path
            relpath = path.relative_path_from(root_path)
            src_path = ::File.join(src_dir, relpath)
            dest_path = ::File.join(dest_dir, relpath)
            dest_mode = path.stat.mode.to_s(8)[-4..-1]

            #p "dest_path #{dest_path}"
            #p "src_path #{src_path}"
            #p "dest_mode #{dest_mode}"

            if path.directory?
              directory "#{relpath} to #{dest_path}" do
                path dest_path
                owner username
                group groupname
                mode dest_mode
                action :create
                recursive true
              end

            elsif path.file?
              remote_file "#{relpath} to #{dest_path}" do
                path dest_path
                owner username
                group groupname
                mode dest_mode
                source "file://#{src_path}"
                action :create
              end
            end
          end
        end

      end

    end
  end

end

