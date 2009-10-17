module Status
  def get_instance_state(instance_id)
    result = ec2.describe_instances(:instance_id => instance_id)
    instance_state = result["reservationSet"]["item"].first["instancesSet"]["item"].first["instanceState"]["name"]
    dns_name = result["reservationSet"]["item"].first["instancesSet"]["item"].first["dnsName"]
    return instance_state, dns_name
  end

  def display_ami_ids(owner_id = nil)
    result = ec2.describe_images(:owner_id => owner_id || config[@customer_key]['amazon_account_number'])
    if result and result["imagesSet"]
      result["imagesSet"]["item"].each {|image| puts "#{white(image["imageId"])} - #{image["imageLocation"]}"}
    else
      puts white("No images.")
    end
  end
  
  def display_instances
    result = ec2.describe_instances
    if result and result["reservationSet"]
      result["reservationSet"]["item"].each do |item|
        instance_id = item["instancesSet"]["item"].first["instanceId"]
        ami_id = item["instancesSet"]["item"].first["imageId"]
        running_state = item["instancesSet"]["item"].first["instanceState"]["name"]
        dns_name = item["instancesSet"]["item"].first["dnsName"]
        puts "Instance Id: #{white(instance_id)} - #{output_running_state(running_state)} (AMI Id: #{white(ami_id)}) #{dns_name}"
      end
    else
      puts white("No instances.")
    end
  end
    
  def display_addresses
    result = ec2.describe_addresses
    if result and result["addressesSet"]
      result["addressesSet"]["item"].each do |ip|
        puts "#{white(ip["publicIp"])} => #{ip["instanceId"].nil? ? 'unassigned' : ip["instanceId"]}"
      end
    else
      puts white("No addresses.")
    end
  end

  def display_volumes
    result = ec2.describe_volumes
    if result and result["volumeSet"]
      result["volumeSet"]["item"].each do |vol|
        instance_id = nil
        if vol["attachmentSet"]
          instance_id = vol["attachmentSet"]["item"].first["instanceId"]
        end
        puts "#{white(vol["volumeId"])} (Size: #{vol["size"]} / Zone: #{vol["availabilityZone"]}) - #{vol["status"]} => #{instance_id.nil? ? 'unassigned' : instance_id}"
      end
    else
      puts white("No volumes.")
    end
  end

  def status_info
    puts "Fetching information about your instances..."
    display_instances
    puts
    puts "Fetching your registered private AMI Id's..."
    display_ami_ids
    puts
    puts "Fetching information about your public IP's..."
    display_addresses
    puts
    puts "Fetching information about your volumes..."
    display_volumes
  end
end
