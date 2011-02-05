module Launch
  def launch
    puts
    puts "Which AMI Id do you want to launch?"
    ami_id = gets
    ami_id = ami_id.lstrip.rstrip

    result = launch_ami(ami_id)

    instance_id = result.instancesSet.item[0].instanceId
    puts "=> Starting Instance Id: #{instance_id}"
    puts

    instance_state = nil
    while(instance_state != 'running')
      instance_state, dns_name = get_instance_state(instance_id)
      puts "=> Checking for running state... #{output_running_state(instance_state)}"
      puts "=> Public DNS: #{white(dns_name)}" if instance_state == 'running'
      sleep 10 unless instance_state == 'running'
    end

    puts

    puts "Do you want to associate a public IP? (leave empty if not)"
    public_ip = gets

    if not public_ip.empty? and public_ip.size > 1
      puts "Associating public IP address... #{public_ip}"
      result = ec2.associate_address(:instance_id => instance_id, :public_ip => public_ip.lstrip.rstrip)
      if result["return"] == "true"
        puts "=> Success."
      end
    end

    puts
    puts "Please enter your volume id (leave empty if you don't want to attach a volume):"
    volume_id = gets

    if not volume_id.empty? and volume_id.size > 1
      puts "Attaching volume... #{volume_id}"
      result = ec2.attach_volume(:volume_id => volume_id.lstrip.rstrip, :instance_id => instance_id, :device => '/dev/sdf')
      if result["return"] == "true"
        puts "=> Success."
      end
    end
  end
  
  def terminate(wait = true)
    instances = get_running_instances_list
    if instances and instances.any?
      puts
      cancel_message(instances)
      sleep 5
      ec2.terminate_instances(:instance_id => instances)
      puts
      puts white("All instances are going to terminate now.")
    else
      puts
      puts white("No running instances.")
    end
  end

  def start_launch_plan
    ami_ids_to_launch = []; detailed_ami_ids_to_launch = []
    puts
    puts "Your Launch Plan:"
    if config[@customer_key]["launch_plan"] and config[@customer_key]["launch_plan"].any?

      launch_plan_groups = config[@customer_key]["launch_plan"].keys.sort

      if self.options[:group]
        puts 
        puts "Existing groups: #{launch_plan_groups.join(", ")}"
        if launch_plan_groups.include?(self.options[:group])
          puts "Targeted Group: #{self.options[:group]}"
          config[@customer_key]["launch_plan"][self.options[:group]].each do |ami_id|
            if (ami_id[1].is_a?(Fixnum))
              puts "#{ami_id[0]} => #{ami_id[1]} Instances to launch"
              ami_ids_to_launch << [ami_id[0], ami_id[1]]
            else
              puts "#{ami_id[0]} => Detailed launch"
              detailed_ami_ids_to_launch << [ami_id[0], ami_id[1]]
            end
          end
        else
          puts white("Targeted Launch plan group '#{self.options[:group]}' not found.")
        end
      else
        launch_plan_groups.each do |launch_plan_group|
          puts
          puts "Group: #{launch_plan_group}"
          if config[@customer_key]["launch_plan"][launch_plan_group] and config[@customer_key]["launch_plan"][launch_plan_group].any?
            config[@customer_key]["launch_plan"][launch_plan_group].keys.each do |ami_id|
              if (config[@customer_key]["launch_plan"][launch_plan_group][ami_id].is_a?(Fixnum))
                puts "#{ami_id} => #{config[@customer_key]["launch_plan"][launch_plan_group][ami_id]} Instances to launch"
                ami_ids_to_launch << [ami_id, config[@customer_key]["launch_plan"][launch_plan_group][ami_id]]
              else
                puts "#{ami_id} => Detailed launch"
                detailed_ami_ids_to_launch << [ami_id, config[@customer_key]["launch_plan"][launch_plan_group][ami_id]]
              end
            end
          else
            puts white("No Ami Id's to launch defined.")
          end
        end
      end
      
      puts
      puts red("Warning: Now launching your plan...")
      puts red("Please press CTRL-C to cancel within the next 5 seconds if this isn't what you want...")
      puts
      sleep 5
      
      ami_ids_to_launch.each do |group_ami_id_pair|
        group_ami_id_pair[1].times {
          puts "Launching #{group_ami_id_pair[0]}..."
          result = launch_ami(group_ami_id_pair[0])
        }
      end
      
      detailed_ami_ids_to_launch.each do |group_ami_id_pair|
        ami_id = group_ami_id_pair[0]
        instance_assignments = group_ami_id_pair[1].split(";")
        puts "Launching #{ami_id} with detailed information..."
        result = launch_ami(ami_id)
        if result and result["instancesSet"]["item"] and (instance_id = result["instancesSet"]["item"][0]["instanceId"])
          instance_state = ''
          while(instance_state != 'running') do
            instance_state, dns_name = get_instance_state(instance_id)
            puts "Running state of instance #{instance_id}: #{output_running_state(instance_state)}"
            sleep 5
          end

          if instance_assignments[0] and not instance_assignments[0].empty?
            puts "Associating IP #{instance_assignments[0]}..."
            result = ec2.associate_address(:instance_id => instance_id, :public_ip => instance_assignments[0])
          end
          
          if instance_assignments[1] and not instance_assignments[1].empty?
            volumes = instance_assignments[1].split(",")
            volumes.each do |volume_pair|
              volume = volume_pair.split("@")
              puts "Attaching volume #{volume[0]} at mount point #{volume[1]}..."
              result = ec2.attach_volume(:volume_id => volume[0], :instance_id => instance_id, :device => volume[1])
            end
          end
        end
      end

      puts white("All instances are launching now...")
    else
      puts white("No launch plan groups defined.")
    end
  end
  
  def launch_ami(ami_id, options = {})
    default_options = {
      :instance_type => config[@customer_key]['instance_type'],
    	:key_name => config[@customer_key]['key'],
    	:availability_zone => config[@customer_key]['availability_zone'],
    	:architecture => config[@customer_key]['architecture'],
    	:image_id => ami_id
    }
    ec2.run_instances(default_options.merge(options))
  end

  private
  def get_running_instances_list
    result = ec2.describe_instances
    if result and result["reservationSet"]
      result["reservationSet"]["item"].collect do |item|
        item["instancesSet"]["item"].first["instanceId"] if item["instancesSet"]["item"].first["instanceState"]["name"] == 'running'
      end.compact
    end
  end
end
