#!/usr/bin/env ruby

require "rubygems"
require 'optparse'

gem 'amazon-ec2'
require 'AWS'

require File.dirname(__FILE__) + '/ec2-instance-manager/ec2_instance_manager'
