# Scripts Cookbook

makes it a little easier to run arbitrary scripts and commands.


## Attributes

`node["scripts"]["bash"]` -- a list of bash scripts to run

```ruby
"scripts" => {
  "bash" => [
    "/path/to/bash/script",
  ]
}
```

`node["scripts"]["shell"]` -- a list of commands to run (usually this is what you want)

```ruby
"scripts" => {
  "shell" => [
    "sudo date",
    "cal"
  ]
}
```

## Notes

If you need to run the scripts as a certain user, you can use sudo:

    sudo -u USERNAME command


## Platform

Ubuntu 14.04, nothing else has been tested

