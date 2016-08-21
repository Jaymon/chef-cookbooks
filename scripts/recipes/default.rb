
name = cookbook_name.to_s
n = node[name]

tmp_dir = Chef::Config[:file_cache_path]


# pp "======================================================================="
# #print node
# pp n
# pp "======================================================================="
if n.has_key?("bash")

  n["bash"].each do |script_path|

    # for some reason, bash script_path do ... didn't work
    execute "bash #{script_path}" do
      action :run
      cwd tmp_dir
    end

  end

end

if n.has_key?("shell")

  n["shell"].each do |cmd|

    # for some reason, bash script_path do ... didn't work
    execute cmd do
      action :run
      cwd tmp_dir
    end

  end

end

