n = node["environ"]["python"]

if n.has_key?("sitecustomize")
  # http://stackoverflow.com/questions/3159945/running-command-line-commands-within-ruby-script
  # http://stackoverflow.com/questions/122327/how-do-i-find-the-location-of-my-python-site-packages-directory
  python_site_packages = %x(python -c "import site; print site.getsitepackages()[0]").strip()
  sitecustomize = ::File.join(python_site_packages, "sitecustomize.py")
  
  # we want to fail if the file doesn't exist
  execute "test -f #{n["sitecustomize"]}" do
    action :run
    notifies :create, "link[link:#{n["sitecustomize"]}]", :immediately
  end

  link "link:#{n["sitecustomize"]}" do
    target_file sitecustomize
    owner "root"
    group "root"
    to n["sitecustomize"]
    action :nothing
    link_type :symbolic
  end
end
