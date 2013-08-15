# http://docs.opscode.com/chef/lwrps_custom.html
actions :set, :file
default_action :set

attribute :name, :kind_of => String, :name_attribute => true
attribute :value, :kind_of => String, :required => true

