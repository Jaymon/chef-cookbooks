# http://docs.opscode.com/essentials_cookbook_attribute_files.html

# the user hash is in username => password format
default["postgres"]["users"] = {"postgres" => "postgres"}

# the databases hash is in username => [dbname1, ...] format
default["postgres"]["databases"] = {}

