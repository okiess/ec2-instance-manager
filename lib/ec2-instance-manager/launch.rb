module Launch
  def launch
    puts
    puts "Which AMI Id do you want to launch?"
    ami_id = gets
    ami_id = ami_id.lstrip.rstrip

    result = ec2.run_instances(
    	:image_id => ami_id,
    	:instance_type => config[@customer_key]['instance_type'],
    	:key_name => config[@customer_key]['key'],
    	:availability_zone => config[@customer_key]['availability_zone']
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
      puts "Warning: Terminating all instances: #{instances.join(", ")}"
      puts "Please cancel within the next 5 seconds..."
      sleep 5
      ec2.terminate_instances(:instance_id => instances)
      puts
      puts "All instances are going to terminate now."
    end
  end

  def get_running_instances_list
    result = ec2.describe_instances
    if result and result["reservationSet"]
      result["reservationSet"]["item"].collect do |item|
        item["instancesSet"]["item"].first["instanceId"] if item["instancesSet"]["item"].first["instanceState"]["name"] == 'running'
      end
    end
  end
end
