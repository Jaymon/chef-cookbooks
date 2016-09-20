# http://docs.opscode.com/essentials_cookbook_attribute_files.html

name = "fail2ban"

default[name] = {}
default[name]['conf_file'] = '/etc/fail2ban/jail.d/jail.local'
