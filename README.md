# Huchen

Huchen is a tool to discover the upstream dependencies of your Opscode Chef cookbooks. Upstream dependencies may include:

* System packages downloaded from apt or yum repositories
* Language specific packages installed by your recipes (Rubygems, PyPI package, npm)
* Other resources downloaded by software you are installing

Currently this is proof of concept so it just does Debian packages but it should be easy to extend.

# How it works
Huchen is made up of three parts:

* A cookbook to capture network traffic that you include at the start of your run_list.
* A Go binary that uses the pcap library to write network traffic to JSON.
* A [Chef handler](http://wiki.opscode.com/display/chef/Exception+and+Report+Handlers) that processes the JSON and outputs the list of upstream dependencies.

# Quick start
See the [huchen-example](https://github.com/acrmp/huchen-example) repository for an example of using Huchen with Vagrant.
