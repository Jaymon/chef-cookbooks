# http://docs.opscode.com/chef/lwrps_custom.html
actions :install, :upgrade
default_action :install

# name of the repo, used for source.list filename
attribute :package_name, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => String, :default => nil
attribute :group, :kind_of => String, :default => nil

