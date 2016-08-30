# http://docs.opscode.com/essentials_cookbook_metadata.html
name              "ssh"
maintainer        "Jay Marcyes"
maintainer_email  "jay@marcyes.com"
description       "provide some ssh fu"
version           "0.1"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports          "ubuntu", "14.04"

recipe            "ssh", "Configure ssh and sshd"
recipe            "ssh::authorized_keys", "add keys from a list of files into ~/.ssh/authorized_keys"
recipe            "ssh::private_keys", "add private key files (like id_rsa) into ~/.ssh/ directory"
recipe            "ssh::known_hosts", "add host keys for domains to ~/.ssh/known_hosts file"

