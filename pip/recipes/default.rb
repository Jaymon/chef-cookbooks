###############################################################################
#
# install Python PIP package manager
#
# @link http://www.pip-installer.org/en/latest/requirements.html#freezing-requirements
# @since  1-31-12
#
###############################################################################

name = cookbook_name.to_s
n = node[name]
#tmp = Chef::Config[:file_cache_path]

###############################################################################
# Get baseline pip setup
###############################################################################

# https://stackoverflow.com/a/50691201/5006
# https://stackoverflow.com/a/33717385/5006
pip_url = "https://bootstrap.pypa.io/get-pip.py"
pip_filepath = ::File.join(::Chef::Config[:file_cache_path], "get-pip.py")

remote_file pip_filepath do
  source pip_url
  action :create_if_missing
  notifies :run, "execute[#{name}-install]", :immediately
end

execute "#{name}-install" do
  command "python \"#{pip_filepath}\""
  action :nothing
  notifies :upgrade, "pip[#{name} upgrade setuptools]", :immediately
end


# package "python-pip" do
#   action :install
#   #notifies :remove, "package[pip remove setuptools]", :immediately
#   notifies :upgrade, "pip[pip upgrade setuptools]", :immediately
# end

# 2-9-15 - this was here for 1.5, but pip >6.0 this messes it all up again, so we are
# no longer going to update setuptools anymore until it breaks again
#pip "setuptools" do
#  action :upgrade
#  flags "--no-use-wheel" # pip 1.5 fix, it tries to use wheel on everything which is in latest setuptools
#end

# package "pip remove setuptools" do
#   package_name "python-setuptools"
#   action :nothing
#   notifies :upgrade, "pip[pip upgrade setuptools]", :immediately
# end

pip "#{name} upgrade setuptools" do
  package_name "setuptools"
  action :nothing
end


###############################################################################
# actually get pip to the correct expected version
###############################################################################
version = n.fetch("version", "")
if !version.empty?
  request_str = "pip==#{version}"
  pip request_str do
    action :install
  end
end


###############################################################################
# fix dumb insecure ssl error
###############################################################################
# NOTE -- as of 3-20-2019 with the update::python recipe this shouldn't be needed anymore, 
# I don't think this codeblock has worked for quite a while anyway
#
# # necessary for eliminating insecure platform warning
# # https://urllib3.readthedocs.org/en/latest/security.html#openssl-pyopenssl
# package "libffi-dev" # needed for ndg-httpsclient to install
# pip "ndg-httpsclient>=0.4.0"
# pip "pyasn1>=0.1.9"
# pip "pyOpenSSL>=0.13"
# 
# ruby_block "configure pip insecure ssl" do
#   block do
#     # TODO -- hook this up for pip2 and pip2.7
#     #pip_path = "/usr/local/bin/pip"
#     pip_path = `which pip`.chomp
#     contents = ::File.read(pip_path)
#     if contents !~ /urllib3.contrib.pyopenssl/
#       ::File.open(pip_path, "w+") do |f|
#         contents.each_line do |line|
#           f.puts(line)
#           if line =~ /import\s+sys/
#             f.puts("try:\n")
#             f.puts("    import urllib3.contrib.pyopenssl\n")
#             f.puts("    urllib3.contrib.pyopenssl.inject_into_urllib3()\n")
#             f.puts("except ImportError:\n")
#             f.puts("    pass\n")
#           end
#         end
#       end
#     end
#   end
# end


###############################################################################
# install any python modules specified in config
###############################################################################
[:install, :upgrade].each do |p_action|
  if n.has_key?(p_action)
    n[p_action].each do |p|
      pip p do
        action p_action
      end
    end
  end
end

