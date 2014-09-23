# Locations Cookbook

place files and folders in the right spot

## Attributes

TBI

## Example

This is what the configuration looks like

    "locations" => {
      "users" => {
        username => {
          "bash_profile" => {
            "src" => ::File.join(ops_base_dir, "bash_firstopinion.sh"),
            "dest" => ::File.join("", "home", username, ".bash_aliases"),
            "mode" => "0644"
          },
          "google_oauth" => {
            # /opt/name should have a config dir in /etc/opt/name
            # http://superuser.com/a/631984
            "dest" => ::File.join("", "etc", ops_base_dir, "google_calendar_oauth.dat"),
            "src" => ::File.join(ops_base_dir, "conf", "google_calendar_oauth_src.dat"),
            "mode" => "0755"
          }
        },
      }
    },

## Platform

Ubuntu 12.04, nothing else has been tested

