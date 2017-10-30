# Pip Cookbook

Handles installing [pip](https://pip.pypa.io/en/stable/) itself and also managing pip libraries.


## Configuration


### keys

#### :install

_list_, use this for any packages you want to install

```ruby
"pip" => {
  :install => [
    "package_name",
    "path/to/requirements.txt",
    "package_with_version==N.N"
  ]
}
```

#### :upgrade

_list_, use this for any packages you want to upgrade each chef run

```ruby
"pip" => {
  :upgrade => [
    "package_name",
  ]
}
```

#### version

string, the version of pip you want to use

```ruby
"pip" => {
  "version" => "8.1.1"
}
```

-------------------------------------------------------------------------------

## Examples

### Use pip from another recipe

```ruby
include_recipe "pip" # you also need depends "pip" in cookbook metadata

pip "package_name" do
  action :install
  flags "--any=pip --flags='you need'",
end
```

* **action** can be either **:install** or **:upgrade**
* **package_name** can be used if you _name_ isn't the package you want to install


