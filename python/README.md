# Python Cookbook

Handles python installations and versioning.


## Attributes

* `common` - dict - place any attributes that should be common across all environments here, this will be merged with the `environments` specific configuration (with the `environments` configuration taking precedence).
* `environments` - dict - The keys are the virtual environment name, the value is the `environments` specific configuration that will be merged with the `common` configuration.


### Environment configuration Attributes

* `version` - string - the python version you want to use for the virtual environment.
* `user` - string - the username you want to own this virtual environment
* `requirements` - array - what you want pip to install in this virtual environment.
* `uwsgi` - string - the uwsgi plugin name if you would like to build a plugin for this environment so you can use it with uwsgi. Some implementation details: 1) you will need to run the `python` cookbook after the `uwsgi` cookbook, and in your uwsgi configuration you will need to specify the plugin you want to use (eg, `"plugin" => "python36"`).


### Example

```ruby
  "python" => {
    "common" => {
      "user" => "USERNAME",
    },
    "environments" => {
      "VIRTUAL_ENVIRONMENT_1" => {
        "version" => "3.6.3",
        "requirements" => [
          "PIP_PACKAGE_1",
          ...
          "PIP_PACKAGE_N",
        ],
      },
      ...
      "VIRTUAL_ENVIRONMENT_N" => {
        ...
      },
    }
  }
}
```


## Development

Some requirements might need customization, you can add a recipe in the format of `package_<PIP_NAME>.rb` which will be auto-discovered and ran instead of the `pyenv_package` resource.