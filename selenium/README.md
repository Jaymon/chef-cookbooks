# Selenium

Everything you need to run selenium and headless browsers


## configuration

* server_version - if you want to peg the selenium server to a certain version.
* python_version - if you want to peg the `pip selenium` call to a specific version.


```ruby
"selenium" => {
  "server_version" => "...",
  "python_version" => "...",
},
```


## Recipes

### selenium

This installs java and the standalone selenium server.


### selenium::chrome

Install Google Chrome and the Selenium Chrome webdriver so you can test the Chrome browser.


### selenium::xvfb

Mainly an internal recipe that is used in `selenium` and `selenium::python`. This installs the X11 virtual frame buffer.

### selenium::python

Installs selenium hooks for python and the hooks needed to run `xvfb` using python.

