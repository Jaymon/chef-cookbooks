# SSH Cookbook

Just some ssh fu.


## Configuration block

```ruby
"ssh" => {
  "users" => ["<USERNAME>"],
  "authorized_keys" => {
    "keys" => [],
  },
  "sshd_config" => {
  }
}
```


## Attributes

### sshd_config

A hash of key/values that will be written to the `/etc/ssh/sshd_config` file.

    "ssh" => {
      "sshd_config" => {
        "LogLevel" => "INFO",
        "PermitRootLogin" => "no",
        "PasswordAuthentication" => "no",
        "X11Forwarding" => "no",
      }
    }


### keys

Configure who has access to the server, authorized keys are `id_rsa.pub` and `id_dsa.pub` files. A list of key files, or public key strings, that will be used to make a master authorized_keys file

    "ssh" => {
      "authorized_keys" => {
        "users" => [...],
        "keys" => ["/path/to/key.pub"]
      }
    }


### private_keys


Configure any private keys a user should have, private keys are `id_rsa` and `id_dsa` files.

    "ssh" => {
      "private_keys" => {
        "users" => [...],
        "keys" => ["/path/to/identity/file"]
      }
    }


### known_hosts

Configure domains that should be recognized right off the bat

    "ssh" => {
      "known_hosts" => {
        "users" => [...],
        "hosts" => ["example.com", "example2.com"]
      }
    }


## Platform

Ubuntu 18.04

