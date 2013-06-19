# Pip Cookbook

Install pip

## Attributes

`node["pip"][:install]` -- a list of python package names to install with pip

`node["pip"][:upgrade]` -- a list of python package names to upgrade with pip

a package name can be a `requirements.txt` file or a `repo+http://example.com...` url or just
a normal `package_name`.

## LWRP

defines a `pip` lwrp that you can use to install python packages:

    pip "package_name" do
      action :install # or :upgrade
      user "username" # optional
      group "group" # optional
    end

## Platform

Ubuntu 12.04, nothing else has been tested

