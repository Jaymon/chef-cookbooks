name = cookbook_name.to_s
#n = node[name]

# NOTE -- these usually need to be run after an apt-get update, but I'll let the
# package cookbook take care of that

# patch shellshocker vulnerability
# https://shellshocker.net/
# you can test vulnerability with this script: https://github.com/hannob/bashcheck/blob/master/bashcheck
execute "apt-get install --only-upgrade bash"
# safe version is: 4.2-2ubuntu2.6

# patch heartbleed
# you can test heartbleed with this site: https://filippo.io/Heartbleed/
execute "apt-get install --only-upgrade openssl"
# safe version is: 1.0.1-4ubuntu5.18
# you can verify your package by doing: dpkg -l | grep openssl

