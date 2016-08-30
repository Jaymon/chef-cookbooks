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
      package "package #{package_action} #{p}" do
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


# 8-29-2016 - somewhere along the way, chef's change to their Node stuff made symbols and strings
# equal keys, so this code is now redundant
# [:install, :upgrade, :remove, :purge].each do |_package_action|
#   [_package_action.to_sym, _package_action.to_s].each do |package_action|
#     p "#{package_action} is the key #{n.has_key?(package_action)}"
#     if n.has_key?(package_action)
#       n[package_action].each do |p|
#         package "package #{package_action} #{p}" do
#           package_name p
#           action package_action.to_sym
#           # goal is to keep the boxes lean, so don't bother with non-essential, if
#           # we need recommended packages we will explicitely add them to our install
#           # list
#           options "--no-install-recommends"
#         end
#       end
#     end
#   end
# end

