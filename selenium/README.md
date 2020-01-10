# Selenium

Everything you need to run selenium and headless browsers


## configuration

* server_version - if you want to peg the selenium server to a certain version.


```ruby
"selenium" => {
  "server_version" => "...",
},
```


## Recipes

### selenium

This installs java and the standalone selenium server.


### selenium::chrome

Install Google Chrome and the Selenium Chrome webdriver so you can test the Chrome browser.


### selenium::firefox

Install Firefox browser


### selenium::xvfb

Installs the X11 virtual frame buffer so browsers that require a window manager can run headless on the command-line.


## Links

* http://pietervogelaar.nl/ubuntu-14-04-install-selenium-as-service-headless

