# Plugin for RMuddy. Should handle basic anti-theft, configuration will be in anti_theft.yaml

class Antitheft < BasePlugin
  #setup method for the plugin.. triggers, var. init and stuff goes here
  def setup
    
    #by default, we do in fact want anti_theft
    
    @anti_theft = true
    
    #Setup your anti-theft triggers here... they might be different for you than me
    
    #souldmasters and hypnosis triggers
    trigger /^(\w+) snaps his fingers in front of you/, :hypnosis
    trigger /^A soulmaster entity lets loose a horrible scream as a dark stream of primal chaos flows from it and into your very being/, :lose_soulmaster
    
    #protect your cash!
    trigger /You get \d+ gold sovereigns from \w+/, :put_gold_away
    
    #and rewear/wield things
    trigger /^You remove a canvas backpack/, :rewear_pack
    trigger /^You remove a suit of scale mail/, :rewear_armor
    trigger /^You remove flowing violet robes./, :rewear_robe
    trigger /^You remove a flowing blue shirt./, :rewear_shirt
    trigger /^You remove tan coloured leggings./, :rewear_trousers
    trigger /^You remove a simple pair of wooden sandals/, :rewear_shoes
    trigger /You cease wielding a cavalry shield in your \w+ hand/, :rewear_shield
    trigger /You drop a cavalry shield./, :pickup_shield
    
    #triggers so you know you put the stuff on
    trigger /You begin to wield a cavalry shield in your left hand/, :reset_shield
    trigger /You are now wearing tan coloured leggings./, :reset_trousers
    trigger /You are now wearing a flowing blue shirt./, :reset_shirt
    trigger /You are now wearing a suit of scale mail./, :reset_armor
    trigger /You are now wearing flowing violet robes./, :reset_robe
    trigger /You are now wearing a canvas backpack./, :reset_pack
    trigger /You are now wearing a simple pair of wooden sandals./, :reset_shoe
    
    #After we gain balance, check if we need to rewear something!
    after Character, :is_balanced, :rewear?
    
    #load the theft database
    unless (File.open("configs/antitheft.yaml") {|fi| @thefthash = YAML.load(fi)}) 
      warn("No configuration file found... you must have the configuration file")
      warn("antitheft.yaml in the configs directory")
    end
    #here, we'll push a bunch of variables out to kmuddy
    @thefthash.each_key {|key| set_kmuddy_variable("theft_#{key}", @thefthash[key])}
  end
  
  def hypnosis (match_object )
    if @anti_theft
      send_kmuddy_command("lose #{match_object[1]}")
      send_kmuddy_command("/echo OK! YOU MAY BE GETTING STOLEN FROM!")
    end
  end
  
  def help
    warn("OK, you asked for it. You must setup the YAML file. It has a format.")
    warn("Each thing should be on a seperate line")
    warn("The format is... on separate lines, mind you, with nothing in front of it")
    warn("item: \"<fully described item, with number here>\"")
    blank_line
    warn("example:")
    warn("pack: \"pack296008\"")
    blank_line
    warn("Items which can be set in the yaml file. There is a set_hash method ... ")
    warn("\"/notify 4567 Antitheft set_hash pack pack1234\" ...\"/notify 4567 ")
    warn("Antitheft set_hash armor scalemail1234\" etc.")
    @thefthash.each_key { |key| warn("#{key}") }
    blank_line
    warn("If you've got alternate gear... say, a sailor's kitbag, or what have")
    warn("you, you'll need to modify the triggers in the antitheft.rb file to ")
    warn("match the appropriate message")
    blank_line
    warn("Finally, you can save your hash to the config file using /notify 4567 ")
    warn("Antitheft save_hash")
  end
  
  def rewear_pack
    if @anti_theft
      @packbalance = true
      send_kmuddy_command("wear #{@thefthash["pack"]}")
    end
  end
  def rewear_shoes
    if @anti_theft
      @shoebalance = true
      send_kmuddy_command("wear #{@thefthash["shoes"]}")
    end
  end
  
  def rewear_shield
    if @anti_theft
      @shieldbalance = true
      send_kmuddy_command("wear #{@thefthash["shield"]}")
    end
  end
  
  def reset_shield
    @shieldbalance = false
  end
  
  def reset_trousers
    @trouserbalance = false
  end
  
  def reset_shirt
    @shirtbalance = false
  end
  
  def reset_armor
    @armorbalance = false      
  end
  
  def reset_robe
    @robebalance = false
  end
  
  def reset_pack
    @packbalance = false
  end
  
  def reset_shoe
    @shoebalance = false
  end
  
  def pickup_shield
    if @anti_theft
      send_kmuddy_command("Get #{@thefthash["shield"]}")
      send_kmuddy_command("wield #{@thefthash["shield"]}")
      @shieldbalance = true
    end
  end
  
  def rewear_shirt
    if @anti_theft
      @shirtbalance = true
      send_kmuddy_command("wear #{@thefthash["shirt"]}")
    end
  end
  
  def rewear_trousers
    if @anti_theft
      @trouserbalance = true
      send_kmuddy_command("wear #{@thefthash["trousers"]}")
    end
  end
  
  def rewear_armor
    if @anti_theft
      @armorbalance = true
      send_kmuddy_command("wear #{@thefthash["armor"]}")
    end
  end
  
  def rewear_robe
    if @anti_theft
      @robebalance = true
      send_kmuddy_command("wear #{@thefthash["robe"]}")
    end
  end
  
  def rewear?
    
    if @soulmaster
      send_kmuddy_command("lose soulmaster")
      @soulmaster = false
        
    elsif @packbalance
      send_kmuddy_command("wear #{@thefthash["pack"]}")
      @packbalance = false
        
    elsif @armorbalance
      send_kmuddy_command("wear #{@thefthash["armor"]}")
      @armorbalance = false
      
    elsif @shieldbalance
      send_kmuddy_command("wear #{@thefthash["shield"]}")
      @shieldbalance = false
        
    elsif @shoebalance
      send_kmuddy_command("wear #{@thefthash["shoes"]}")
        
    elsif @shirtbalance
      send_kmuddy_command("wear #{@thefthash["shirt"]}")
      @shirtbalance = false
        
    elsif @trouserbalance
      send_kmuddy_command("wear #{@thefthash["trousers"]}")
      @trouserbalance = false
      
    elsif @robebalance
      send_kmuddy_command("wear #{@thefthash["robe"]}")
      @robebalance = 0
    end
    
  end
  
  def print_hash
    warn("Printing anti-theft database, this may be spammy")
    @thefthash.each_key { |key| warn("#{key}:    #{@thefthash[key]}" ) }
  end
  
  def put_gold_away
    if @anti_theft
      send_kmuddy_command("put sovereigns in #{@thefthash["pack"]}")
    end
  end
  
  def test (key = "pack")
    send_kmuddy_command("/echo #{@thefthash[key]}")
  end
  
  def lose_soulmaster
    send_kmuddy_command("lose soulmaster")
    @soulmaster = true
  end
  
  def set_hash (key = '', value = '')
    if (key == '' && value == '')
      warn("You must tell me what article you are trying to protect, and which")
      warn("one it is supposed to be specifically!")
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
  
  def theft_on
    @anti_theft = true
  end
  
  def theft_off
    @anti_theft = false
  end
  
  def save_hash
    warn("Saving antitheft configuration")
    unless (File.open("configs/antitheft.yaml", "w") {|fi| @thefthash = YAML.dump(fi)}) 
      warn("Could not write configuration file for antitheft")
    end
  end
  
end

