# Motd Cookbook

configure the motd message

## Attributes

### message

A Ruby format string with params in the form of: `this is the string with %{param_name}`.

### params

A dictionary with symbol keys that correspond to the needed params in the `message` and the values you want to substitute into the string.


## Example

```ruby
"motd" => {
  "message" => [
    "%{box_name} last provisioned on %{date}",
    "",
    "role: %{role}",
    "environment: %{environment}",
    "server branch: %{server_branch}",
  ].join("\n"),
  "params" => {
    :box_name => box_name,
    :date => ::Time.now.strftime("%A, %B %d, %Y at %H:%M"),
    :role => chef_role,
    :environment => environment,
    :server_branch => server_branch,
  }
}
```

## Alternatives

Instead of using the `/etc/motd` file, you could also use `/etc/update-motd.d/99-footer`


## Platform

Ubuntu 14.04, nothing else has been tested

