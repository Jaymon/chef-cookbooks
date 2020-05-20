name = cookbook_name.to_s
n = node[name]

if !n['timezone'].empty?

  execute "#{name} set timezone to #{n['timezone']}" do
    command "timedatectl set-timezone #{n['timezone']}"
  end

end
