n = node["environ"]["python"]

if n.has_key?("sitecustomize")
  # http://stackoverflow.com/questions/3159945/running-command-line-commands-within-ruby-script
  # http://stackoverflow.com/questions/122327/how-do-i-find-the-location-of-my-python-site-packages-directory
  python_site_packages = %x(python -c "import site; print site.getsitepackages()[0]").strip()
  sitecustomize = ::File.join(python_site_packages, "sitecustomize.py")
  
  # we want to fail if the source file doesn't exist
  execute "test -f #{n["sitecustomize"]}" do
    action :run
    notifies :create, "link[link:#{sitecustomize}]", :immediately
  end

  link "link:#{sitecustomize}" do
    target_file sitecustomize
    owner "root"
    group "root"
    to n["sitecustomize"]
    action :nothing
    link_type :symbolic
  end
end

if n.has_key?("usercustomize")

  n["usercustomize"].each do |username, f|

    # this command possibly only works if chef is run as root (which is probably always, but I'm noting it anyway)
    # http://unix.stackexchange.com/questions/1087/su-options-running-command-as-another-user
    python_site_packages = %x(su -c 'python -c "import site; print site.USER_SITE"' #{username}).strip()
    usercustomize = ::File.join(python_site_packages, "usercustomize.py")

    directory python_site_packages do
      owner username
      group username
      recursive true
      action :create
    end

    # name has to be unique otherwise resource will keep getting updated in the loop
    execute "assure_usercustomize_for_#{username}" do
      command "test -f #{f}"
      action :run
      notifies :create, "link[link:#{usercustomize}]", :immediately
    end

    link "link:#{usercustomize}" do
      target_file usercustomize
      owner username
      group username
      to f
      action :nothing
      link_type :symbolic
    end
  end
end
