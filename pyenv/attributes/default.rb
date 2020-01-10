# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "pyenv"

default[name] = {}
default[name]["versions"] = {} # username keys with a version array
default[name]["dir"] = ::File.join("", "opt", "pyenv")
default[name]["repo"] = "https://github.com/pyenv/pyenv.git"
default[name]["bash"] = "eval \"$(pyenv init -)\""
default[name]["plugins"] = {
  "pyenv-virtualenv" => { # https://github.com/pyenv/pyenv-virtualenv
    "repo" => "https://github.com/pyenv/pyenv-virtualenv.git",
    "bash" => "eval \"$(pyenv virtualenv-init -)\""
  }
}

