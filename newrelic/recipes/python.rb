# https://docs.newrelic.com/docs/agents/python-agent/getting-started/python-agent-quick-start
# https://docs.newrelic.com/docs/agents/python-agent/installation-configuration/python-agent-logging
# https://docs.newrelic.com/docs/agents/python-agent/getting-started/new-relic-python
# https://docs.newrelic.com/docs/agents/python-agent/installation-configuration/python-agent-integration
# https://docs.newrelic.com/docs/agents/python-agent/hosting-mechanisms/python-agent-uwsgi
# https://docs.newrelic.com/docs/agents/python-agent/installation-configuration/python-agent-installation
# https://docs.newrelic.com/docs/apm/new-relic-apm/installation-configuration/installing-agent
name = cookbook_name.to_s
n = node[name]


###############################################################################
# prerequisites
###############################################################################
include_recipe "pip"


###############################################################################
# install it
###############################################################################
package_name = "newrelic"
if n.has_key?("version")
  request_str += "==#{n['version']}"
end

pip package_name


###############################################################################
# configure it
###############################################################################
if n.has_key?("apps")
  include_recipe "#{name}::app"
end

