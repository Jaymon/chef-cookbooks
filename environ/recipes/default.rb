n = node["environ"]

if n.has_key?("global")

  n["global"].each do |env_action, env_list|
    env_list.each do |key, val|

      environ key do
        value val
        action env_action
      end

    end

  end

end

