# http://docs.opscode.com/essentials_cookbook_attribute_files.html
name = "pyenv"

default[name] = {}
default[name]["versions"] = {}
default[name]["dir"] = ::File.join("", "opt", "pyenv")
default[name]["repo"] = "https://github.com/yyuu/pyenv.git"

