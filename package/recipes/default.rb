##
# arbitrarily add packages 
# 
# this is for when you want to add a whole bunch of packages and you don't want to
# create a recipe for each package
#
# @link http://wiki.opscode.com/display/chef/Resources#Resources-Package
# @since  1-31-12 
##

include_recipe "package::update"

n = node["package"]


[:install, :upgrade, :remove, :purge].each do |package_action|

  if n.has_key?(package_action)

    n[package_action].each do |package_name|
    
      package package_name do
        action package_action
      end
      
    end
  
  end
    
end
