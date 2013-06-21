n = node["diff"]

n["patch"].each do |diff_hash|
  orig_file = diff_hash['file']
  patch_diff = diff_hash['diff']
  checksum = diff_hash['file_md5']

  execute 'patch "#{orig_file}" < "#{patch_diff}"' do
    user "root"
    action :run
    # http://stackoverflow.com/questions/3679296/only-get-hash-value-using-md5sum-without-filename
    only_if 'test "#{checksum}" == "$(md5=$(md5sum "#{orig_file}"); echo "${md5%% *}")"'
  end

end

