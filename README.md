ec2-instance-manager
====================

ec2-instance-manager is a command line utility written in ruby to manage Amazon EC2 instances and clusters (launchplan groups) for multiple AWS accounts (customer config keys).

You can launch and terminate EC2 instances, create whole launchplans of instances divided into groups, start all launchplan groups or start a specific launchplan group, assign public IP's and attach volumes.


Installation:
-------------

	[sudo] gem install amazon-ec2 ec2-instance-manager


Configuration:
--------------

You can either run ec2-instance-manager from a local "config.yml" in your current work directory or use a global ".ec2_instance_manager_config.yml" in your home directory. If a local configuration file in the current work directory is found, it has precendence over the global configuration file.

There are basically two types of launchplan instance definitions:

1. Simple
2. Detailed

With the simple type you can quickly launch a number of instances by their AMI ID. This type uses the default settings for availability_zone, instance_type and architecture.

If you need fine-grained control over each instance, you should go for the detailed launchplan instance definition. You can name each instance in a group. Make sure the instance nicknames are unique.

Each definition consists of the following required values: 

* AMI ID
* Architecture (x86_64 or i386)
* EC2 Instance Type

You can also specify the following optional values:

* Elastic IP to assign
* Volumes to attach at a given mountpoint (Comma separated)

The instances are created sequentially in order of their definition.

Configuration example:

	default: # Default customer config key
  		amazon_access_key_id: YOUR_ACCESS_KEY
  		amazon_secret_access_key: YOUR_SECRET
  		amazon_account_number: YOUR_CUSTOMER_NUMBER
  		ec2_server_region: "eu-west-1.ec2.amazonaws.com"
  		key: YOUR_SSH_KEY
  		availability_zone: eu-west-1a
  		instance_type: t1.micro
  		architecture: x86_64 #i386
  		launch_plan:
    		webservers:
      			"ami_id_xxx1": 2
    		dbservers:
      			"ami_id_xxx2": 1
			detailed:
	  			"appserver1": "ami_id_xxx3;x86_64;t1.micro;"
	  			"appserver2": "ami_id_xxx3;x86_64;t1.micro;192.168.1.1;vol-xxx1@/dev/sdf,vol-xxx2@/dev/sdg"
	  			"appserver3": "ami_id_xxx3;x86_64;t1.micro;;vol-xxx3@/dev/sdf,vol-xxx4@/dev/sdg"


Please have a look at the "config.yml.sample" for further configuration examples.


Usage:
------

Run ec2-instance-manager --help for options and commands.

	ec2-instance-manager 0.4.0 [options]
		-s, --status                     Status only
    	-t, --terminate-all              Terminates all instances running under a customer config key
    	-l, --start-launch-plan          Starts a launch plan under a customer config key
    	-g, --group LAUNCH_GROUP_NAME    Starts a launch plan group under a customer config key
    	-c, --config CONFIG_KEY          Sets the customer config key
    	-h, --help                       Display this screen


Examples:
---------

Checking the status of your instances/cluster:

	ec2-instance-manager -c YOUR_CONFIG_KEY -s

Terminating all instances:

	ec2-instance-manager -c YOUR_CONFIG_KEY -t
	
Terminating all instances of a launch group:
	
	ec2-instance-manager -c YOUR_CONFIG_KEY -g LAUNCH_GROUP_NAME -t

Launching all groups of your launchplan:

	ec2-instance-manager -c YOUR_CONFIG_KEY -l
	
Launching a specific group of your launchplan:

	ec2-instance-manager -c YOUR_CONFIG_KEY -g LAUNCH_GROUP_NAME -l
	
Launching an individual instance without a definition (launch console):

	ec2-instance-manager -c YOUR_CONFIG_KEY


Copyright
---------

Copyright (c) 2009-2011 Oliver Kiessler. See LICENSE for details.
