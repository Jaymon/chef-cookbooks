##
# arbitrarily add packages 
# 
# this is for when you want to add a whole bunch of packages and you don't want to
# create a recipe for each package
#
# @link http://wiki.opscode.com/display/chef/Resources#Resources-Package
# @since  1-31-12 
##

name = cookbook_name.to_s
n = node[name]


include_recipe "package::update"


[:install, :upgrade, :remove, :purge].each do |package_action|
  if n.has_key?(package_action)
    n[package_action].each do |p|
      package "#{name} #{package_action} #{p}" do
        package_name p
        action package_action.to_sym
        # goal is to keep the boxes lean, so don't bother with non-essential, if
        # we need recommended packages we will explicitely add them to our install
        # list
        options "--no-install-recommends"
      end
    end
  end
end

