# Huchen

Huchen is a tool to discover the upstream dependencies of your Opscode Chef cookbooks. Upstream dependencies may include:

* OS packages downloaded by your OS package manager
* Language specific packages installed by your recipes (Rubygems, PyPI package)
* Other resources downloaded by software you are installing

# Why?

Infrastructure as code promises you can reproducibly create entire environments from source code.

Awesome... except:

* Your converge fails because you depend on OS package repositories being available and not breaking.
You probably set up a local repo mirror.
* Then your converge fails because you aren't vendoring and RubyGems is having a bad day.
* Or it fails because you're using RVM head.
* Or it fails because the Chef recipe you are using goes around your package manager to install software.
* Or it fails because it starts a daemon which wants to retrieve a XML DTD on startup.

Adding `huchen::default` to your run_list doesn't fix any of this. In fact it's yet another dependency.

But it is a convenient way to see during development what stuff your build actually depends on.

# How it works
Huchen is made up of three parts:

* A cookbook to capture network traffic that you include at the start of your run_list.
* A Go binary that uses the pcap library to write network traffic to JSON.
* A [Chef handler](http://wiki.opscode.com/display/chef/Exception+and+Report+Handlers) that processes the JSON and
outputs the list of upstream dependencies.

# Quick start
See the [huchen-example](https://github.com/acrmp/huchen-example) repository for an example of using Huchen with Vagrant.
