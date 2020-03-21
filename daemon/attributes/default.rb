name = "daemon"

n = {}

# internal configuration, config block can override this, then services block will
# override config
n["config_default"] = {
  "action" => :start
}

# global configuration that will be merged into each daemon's specific configuration
n["config"] = {}

# the keys are the daemon names and the values are the config dicts that will be merged
# with config
n["services"] = {}

n['dirs'] = {
  "service" => ::File.join("", "etc", "systemd", "system"),
}

default[name] = n

