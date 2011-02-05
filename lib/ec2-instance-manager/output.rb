module Output
  def output_running_state(running_state)
    if running_state == 'running'
      green(running_state)
    elsif running_state == 'terminated' or running_state == 'shutting-down'
      red(running_state)
    elsif running_state == 'pending'
      yellow(running_state)
    else
      running_state
    end
  end
  
  def cancel_message(instances)
    puts red("Warning: Terminating all instances: #{instances.join(", ")}")
    puts red("Please press CTRL-C to cancel within the next 5 seconds if this isn't what you want...")
  end
  
  def green(str)
    "\033[32m#{str}\033[0m" 
  end
  
  def red(str)
    "\033[31m#{str}\033[0m"
  end
  
  def yellow(str)
    "\033[33m#{str}\033[0m"
  end
  
  def white(str)
    "\033[1m#{str}\033[0m"
  end
end
