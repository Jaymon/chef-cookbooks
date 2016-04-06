require "pathname"

name = cookbook_name.to_s
n = node[name]

if n && n.has_key?('users') && !n['users'].empty?

  n['users'].each do |username, files|
    files.each do |dname, d|
      resources = []
      src_dir = ''
      src_file = d.fetch('src', '')
      dest_dir = ''
      dest_file = d['dest']
      src_content = d.fetch("content", "")
      groupname = d.fetch('group', username)
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
          if src_content.empty?
            dest_dir = dest_file
          end
          #raise "no local source file found at location #{src_file}"

        end
      end

  #     p "dest_dir #{dest_dir}"
  #     p "src_dir #{src_dir}"
  #     p "src_file #{src_file}"
  #     p "dest_file #{dest_file}"

      if !dest_dir.empty?
        r = directory "#{dname} dest_dir" do
          path dest_dir
          owner username
          group groupname
          action :create
          recursive true
          #not_if { ::File.directory?(dest_dir) }
        end
        resources << r
      end

      if !src_file.empty?
        r = remote_file dname do
          path dest_file
          owner username
          group groupname
          mode d.fetch('mode', nil)
          source src_file
          action d.fetch('action', :create)
        end
        resources << r

      elsif !src_dir.empty?

        #p "dest_dir #{dest_dir}"
        #p "src_dir #{src_dir}"

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
              r = directory "#{relpath} to #{dest_path}" do
                path dest_path
                owner username
                group groupname
                mode dest_mode
                action :create
                recursive true
              end
              resources << r

            elsif path.file?
              r = remote_file "#{relpath} to #{dest_path}" do
                path dest_path
                owner username
                group groupname
                mode dest_mode
                source "file://#{src_path}"
                action :create
              end
              resources << r
            end
          end
        end

      elsif !src_content.empty?
        # https://docs.chef.io/resource_file.html
        r = file "#{dname} file from content" do
          path dest_file
          content src_content
          owner username
          group groupname
          mode d.fetch('mode', nil)
          action d.fetch('action', :create)
        end
        resources << r
      end

      resources.each do |r|
        d.fetch('notifies', []).each do |params|
          r.notifies(*params)
        end
      end

    end

  end

end

