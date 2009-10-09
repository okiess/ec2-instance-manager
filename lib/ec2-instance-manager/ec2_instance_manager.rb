require File.dirname(__FILE__) + '/status'
require File.dirname(__FILE__) + '/launch'

class Ec2InstanceManager
  include Status
  include Launch
  VERSION = '0.2'
  
  attr_reader :config, :customer_key, :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin
    options = {}
    
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: ec2-instance-manager [options]"

      options[:status] = false
      opts.on( '-s', '--status', 'Status only' ) do
        options[:status] = true
      end
      
      options[:terminate] = false
      opts.on( '-t', '--terminate-all', 'Terminates all instances running under a config key' ) do
        options[:terminate] = true
      end
      
      options[:config] = nil
      opts.on( '-c', '--config CONFIG_KEY', 'Sets the config key' ) do |key|
        options[:config] = key
      end

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end
    end

    optparse.parse!
    @options = options
  end

  def config; @config ||= read_config; end
  def read_config
    if File.exists?("config.yml")
      @config = YAML.load(File.read("config.yml"))
    else
      begin
        @config = YAML.load(File.read("#{ENV['HOME']}/.ec2_instance_manager_config.yml"))
      rescue Errno::ENOENT
        raise "config.yml expected in current directory or ~/.ec2_instance_manager_config.yml"
      end
    end
  end

  def ec2
    @ec2 ||= AWS::EC2::Base.new(:access_key_id => config[@customer_key]['amazon_access_key_id'],
      :secret_access_key => config[@customer_key]['amazon_secret_access_key'])
  end

  def run
    puts "EC2 Instance Manager"
    puts
    unless options[:config]
      puts "Which customer config do you want to use? (#{config.keys.join(", ")})"
      @customer_key = gets
      @customer_key = @customer_key.rstrip.lstrip
      @customer_key = 'default' if @customer_key.empty?
    else
      @customer_key = options[:config]
    end

    puts "Configuration: #{@customer_key}"
    puts "AMAZON_ACCESS_KEY_ID: #{config[@customer_key]['amazon_access_key_id']}"
    puts "KEY: #{config[@customer_key]['key']}"
    puts "ZONE: #{config[@customer_key]['availability_zone']}"
    puts
    
    status_info

    if options[:terminate]
      terminate
    else
      launch unless options[:status]
    end
  end
end
