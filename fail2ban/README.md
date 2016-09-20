# Fail2ban Cookbook

Install and configure fail2ban via /etc/fail2ban/jail.d/fo_config.local

## Attributes

`node["fail2ban"]` -- a dict to configure fail2ban

## Example

    'fail2ban' => {
      'ssh' => {
        'enabled' => 'true',
        'maxretry' => '4',
      },
    },

See [Fail2ban Manual](http://www.fail2ban.org/wiki/index.php/Manual) for more infomation.

## Platform

Ubuntu 14.04, nothing else has been tested
