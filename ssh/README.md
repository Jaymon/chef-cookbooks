# SSH Cookbook

Just some ssh fu 

## Attributes

### Recipes

* ssh

    This will configure ssh

        "ssh" => {
          "sshd_config" => {
            "LogLevel" => "INFO",
            "PermitRootLogin" => "no",
            "PasswordAuthentication" => "no",
            "X11Forwarding" => "no",
          }
        }

    `node["ssh"]["sshd_config"]` -- a hash of key/values that will be written to the `/etc/ssh/sshd_config` file.


* ssh::authorized_keys

    Configure who has access to the server

        "ssh" => {
          "authorized_keys" => [...]
        }


    `node["ssh"]["authorized_keys"]` -- a list of key files that will be used to make a master authorized_keys file


* ssh:private_keys

    Configure any private keys a user should have, private keys are `id_rsa` and `id_dsa` files

        "ssh" => {
          "private_keys" => {
            "users" => [...],
            "keys" => ["/path/to/identity/file"]
          }
        }


* ssh::known_hosts

    Configure domains that should be recognized right off the bat

        "ssh" => {
          "known_hosts" => {
            "users" => [...],
            "hosts" => ["example.com", "example2.com"]
          }
        }


## Platform

Ubuntu 14.04, nothing else has been tested

