#!/usr/bin/env ruby

require "rubygems"
gem 'amazon-ec2'
require 'AWS'

require File.dirname(__FILE__) + '/ec2_methods'

class Ec2InstanceManager
  include Ec2Methods
  VERSION = '0.1'
  
  attr_reader :options, :config, :customer_key

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin
    @config = YAML.load(File.read("config.yml"))
  end

  def run
    puts "EC2 Instance Manager"
    puts
    puts "Which customer config do you want to use? (#{@config.keys.join(", ")})"
    @customer_key = gets
    @customer_key = @customer_key.rstrip.lstrip
    @customer_key = 'default' if @customer_key.empty?

    @ec2 = AWS::EC2::Base.new(:access_key_id => @config[@customer_key]['amazon_access_key_id'],
      :secret_access_key => @config[@customer_key]['amazon_secret_access_key'])

    puts "Configuration: #{@customer_key}"
    puts "AMAZON_ACCESS_KEY_ID: #{@config[@customer_key]['amazon_access_key_id']}"
    puts "KEY: #{@config[@customer_key]['key']}"
    puts "ZONE: #{@config[@customer_key]['availability_zone']}"
    puts
    
    status_info

    puts
    puts "Which AMI Id do you want to launch?"
    ami_id = gets
    ami_id = ami_id.lstrip.rstrip

    result = @ec2.run_instances(
    	:image_id => ami_id,
    	:instance_type => @config[@customer_key]['instance_type'],
    	:key_name => @config[@customer_key]['key'],
    	:availability_zone => @config[@customer_key]['availability_zone']
    )

    instance_id = result.instancesSet.item[0].instanceId
    puts "=> Starting Instance Id: #{instance_id}"
    puts

    instance_state = nil
    while(instance_state != 'running')
      instance_state, dns_name = get_instance_state(instance_id)
      puts "=> Checking for running state... #{instance_state}"
      puts "=> Public DNS: #{dns_name}" if instance_state == 'running'
      sleep 10 unless instance_state == 'running'
    end

    puts

    puts "Do you want to associate a public IP? (leave empty if not)"
    public_ip = gets

    if not public_ip.empty? and public_ip.size > 1
      puts "Associating public IP address... #{public_ip}"
      result = @ec2.associate_address(:instance_id => instance_id, :public_ip => public_ip.lstrip.rstrip)
      if result["return"] == "true"
        puts "=> Success."
      end
    end

    puts
    puts "Please enter your volume id (leave empty if you don't want to attach a volume):"
    volume_id = gets

    if not volume_id.empty? and volume_id.size > 1
      puts "Attaching volume... #{volume_id}"
      result = @ec2.attach_volume(:volume_id => volume_id.lstrip.rstrip, :instance_id => instance_id, :device => '/dev/sdf')
      if result["return"] == "true"
        puts "=> Success."
      end
    end
  end
end
