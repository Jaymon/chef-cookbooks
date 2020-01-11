# Pyenv Cookbook

Installs [Pyenv](https://github.com/pyenv/pyenv/) globally, each user of the system can then install any versions they want to use and those versions should be managed separately. So user `foo` could install `3.8.1` and install a bunch of packages and user `bar` could also install `3.8.1` and install different packages and they shouldn't clobber each other.


## Attributes

`node["pyenv"]["versions"]` -- dict -- each key will be a username, with a dict value will be a list of python versions to install:

```ruby
"pyenv" => {
  "versions" => {
    "USERNAME" => [
      "3.6.3",
      "2.7.14",
    ]
  }
}
```


## TODO

There is no way to use the virtualenv functionality outside of the `python` cookbook right now. I think I might change the config format to:

```ruby
"pyenv" => {
  "versions" => {
    "VERSION" => {
      "user" => "USERNAME",
      "virtualenv" => "VENV_NAME",
    }
  }
}
```

which would be more verbose but would enable the virtualenv stuff, or maybe I just don't worry about and if you want virtualenv support you should use the `python` cookbook instead. I could also merge this into the `python` cookbook so it is all in one place.

## Customization

Because this uses [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv), it will automatically activate/deactivate virtualenvs on entering/leaving directories which contain a `.python-version` file that contains the name of a valid virtual environment as shown in the output of `pyenv virtualenvs`.

## Platform

Ubuntu 14.04, nothing else has been tested

