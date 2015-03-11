# SSH Cookbook

Just some ssh fu 

## Attributes

### Attributes recipe ssh::authorized_keys uses

`node["ssh"]["authorized_keys"]` -- a list of key files that will be used to make a master authorized_keys file

`node["ssh"]["sshd_config"]` -- a hash of key/values that will be written to the `/etc/ssh/sshd_config` file.

## Platform

Ubuntu 12.04, nothing else has been tested

