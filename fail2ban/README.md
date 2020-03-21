# Fail2ban Cookbook

Install and configure fail2ban

## Links

* [Fail2ban Manual](http://www.fail2ban.org/wiki/index.php/Manual)


## Configuration block

```ruby
"fail2ban" => {
  "<SERVICE_NAME>" => {
  },
}
```


## Example

    'fail2ban' => {
      'ssh' => {
        'enabled' => 'true',
        'maxretry' => '4',
      },
    },


## Platform

Ubuntu 18.04, nothing else has been tested
