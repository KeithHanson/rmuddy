# Plugin for RMuddy. Should handle basic anti-theft, configuration will be in anti_theft.yaml

class Antitheft < BasePlugin
  #setup method for the plugin.. triggers, var. init and stuff goes here
  def setup
    
    #Setup your anti-theft triggers here... they might be different for you than me
    trigger /^(\w+) snaps his fingers in front of you/, :hypnosis
    trigger /^A soulmaster entity lets loose a horrible scream as a dark stream of primal chaos flows from it and into your very being/, :lose_soulmaster
    trigger /You get \d+ gold sovereigns from \w+/, :put_gold_away
    trigger /^You remove a canvas backpack/, :rewear_pack
    trigger /^You remove a suit of scale mail/, :rewear_armor
    trigger /^You remove flowing violet robes./, :rewear_robe
    
    #After we gain balance, check if we need to rewear something!
    after Character, :is_balanced, :rewear?
    
    unless (File.open("configs/antitheft.yaml") {|fi| @thefthash = YAML.load(fi)}) 
      warn("No configuration file found... you must have the configuration file antitheft.yaml in the configs directory")
    end
  end
  
  def help
    warn("OK, you asked for it. You must setup the YAML file. It has a format. Each thing should be on a seperate line")
    warn("The format is... on separate lines, mind you, with nothing in front of it")
    warn("item: \"<fully described item, with number here>\"")
    blank_line
    warn("example:")
    warn("pack: \"pack296008\"")
    blank_line
    warn("You can use \"/notify 4567 Antitheft set_hash pack pack296008\" to accomplish the same result as the line above")
    warn("and this module should have been packaged with a template antitheft.yaml file with it")
    blank_line
    warn("Items which can be set in the yaml file. There is a set_hash method ... ")
    warn("\"/notify 4567 Antitheft set_hash pack pack1234\" ...\"/notify 4567 Antitheft set_hash armor scalemail1234\" etc.")
    @thefthash.each_key { |key| warn("#{key}") }
    blank_line
    warn("If you've got alternate gear... say, a sailor's kitbag, or what have")
    warn("you, you'll need to modify the triggers in the antitheft.rb file to match the appropriate message")
    blank_line
    warn("Finally, you can save your hash to the config file using /notify 4567 Antitheft save_hash")
  end
  
  def rewear_pack
    @packbalance = true
  end
  
  def rewear_armor
    @armorbalance = true
  end
  
  def rewear_robe
    @robebalance = true
  end
  
  def rewear?
    if @armorbalance
      send_kmuddy_command("wear #{@thefthash[armor]}")
      @armorbalance = false
    end
    
    if @packbalance
      send_kmuddy_command("wear #{@thefthash[pack]}")
      @packbalance = false
    end
    
    if @robebalance
      send_kmuddy_command("wear #{@thefthash[robe]}")
      @robebalance = 0
    end
  end
  
  def put_gold_away
    send_kmuddy_command("put sovereigns in #{@thefthash[pack]}")
  end
  
  def set_hash (key = '', value = '')
    if (key == '' && value == '')
      warn("You must tell me what article you are trying to protect, and which one it is supposed to be specifically!")
    elsif (key != '' && value =='')
      warn("You have to tell me what #{key} is your's, specifically!")
    elsif (key == '' && value != '')
      warn("You have to tell me what kind of item #{value} is, so we can properly protect it!")
    else
      @thefthash[key] = value
      warn("Setting item #{key} to your specific item, #{value}")
      save_hash
    end
  end
  
  def save_hash
    warn("Saving antitheft configuration")
    unless (File.open("configs/antitheft.yaml", "w") {|fi| @thefthash = YAML.dump(fi)}) 
      warn("Could not write configuration file for antitheft")
    end
  end
  
end

