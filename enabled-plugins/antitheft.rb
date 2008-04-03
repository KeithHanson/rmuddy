# Plugin for RMuddy. Should handle basic anti-theft, configuration will be in anti_theft.yaml

class Antitheft < BasePlugin
  #setup method for the plugin.. triggers, var. init and stuff goes here
  def setup
    
    #by default, we do in fact want anti_theft
    
    @anti_theft = true
    @trigger_setup = false
    
    #Setup your anti-theft triggers here... they might be different for you than me
    
    #souldmasters and hypnosis triggers
    trigger /^(\w+) snaps his fingers in front of you/, :hypnosis
    trigger /^A soulmaster entity lets loose a horrible scream as a dark stream of primal chaos flows from it and into your very being/, :lose_soulmaster
    
    #protect your cash!
    trigger /You get \d+ gold sovereigns from \w+/, :put_gold_away
    
    #load the theft database
    unless (File.open("configs/antitheft.yaml") {|file| @thefthash = YAML.load(file)}) 
      warn("No configuration file found... you must have the configuration file")
      warn("antitheft.yaml in the configs directory")
    end

    #These are the items from the configuration that will require balance, and so
    #the methods get defined a bit differently.
    @balance_items = []

    #If an item in the hash is found with the key: "balance_items", delete it off the main hash
    #and stuff it into it's own variable.
    if @thefthash.keys.include?("balance_items")
      @balance_items = @thefthash.delete("balance_items")
    end

    #here, we'll push a bunch of variables out to kmuddy
    @thefthash.each_key {|key| set_kmuddy_variable("theft_#{key}", @thefthash[key])}

    #This is the auto-setup. We basically trigger off of an ii
    trigger /^You are wearing:/, :enable_trigger_setup
    
    #Now, we know we'll only get wearable items. 
    #We'll need to setup for wielding as well.
    trigger /^\s*(\w*)\s*(.*)$/, :setup_trigger

    #I left this manual trigger in just so I'll remember to handle it a bit later
    #We want to be able to dynamically do this though.
    trigger /You drop a cavalry shield./, :pickup_shield
    
    #After we gain balance, check if we need to rewear something!
    after Character, :is_balanced, :rewear?

    #Once we see a character's prompt, stop collecting and creating triggers.
    after Character, :set_extended_stats, :disable_trigger_setup
    after Character, :set_simple_stats, :disable_trigger_setup

    #For some reason, our send_kmuddy_commands aren't working in a setup method. *FEH!*
    #I use this as a one time variable to call a setup method.
    @needs_setup = true
  end
  
  

  def enable_trigger_setup
    @trigger_setup = true
  end

  def disable_trigger_setup
    #Fire off an ii if we haven't already.
    if @needs_setup == true
      @needs_setup = false
      send_kmuddy_command("ii")
      send_kmuddy_command("more")
    else
      #otherwise, disable the trigger setups
      @trigger_setup = false
    end
  end

  #The Magic!
  def setup_trigger(match_object)
    #If we're setting up triggers (after an ii), do the following...
    if @trigger_setup

      #Move through each key/value pair in thefthash
      @thefthash.each_pair do |key, value|
        #if the value equals the matched object in ii...
        if value == match_object[1]
          #we create rewear/reset method names...
          rewear_method_string = "rewear_#{key}"
          reset_method_string = "reset_#{key}"

          #Make sure we haven't already defined these methods... they really only need to be defined once.
          unless self.methods.include?(rewear_method_string)

            #Check to see if this is a balance required item... If not...
            unless @balance_items.include?(key)
              #eval the string of the method. Basically, this unreadable mess sets the @keybalance instance var to true,
              #and sends kmuddy the command to rewear.
              eval("def #{rewear_method_string}\n if @anti_theft\n@#{key}balance = true\n send_kmuddy_command(\"wear #{value}\")\n end\nend")
            else
              #If this is a balance item, we simple set the balance to true, and wait for our balanced
              #trigger to fire.
              eval("def #{rewear_method_string}\n if @anti_theft\n@#{key}balance = true\n end\nend")
            end
            #all items have a reset method.
            eval("def #{reset_method_string}\n@#{key}balance = false\nend")
  
            #all items will have the same triggers
            trigger Regexp.new("You remove #{match_object[2]}"),  rewear_method_string.to_sym
            trigger Regexp.new("You are now wearing #{match_object[2]}"), reset_method_string.to_sym
          end
        end
      end
    end
  end
  

  def hypnosis (match_object)
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
  
  def pickup_shield
    if @anti_theft
      send_kmuddy_command("Get #{@thefthash["shield"]}")
      send_kmuddy_command("wield #{@thefthash["shield"]}")
      @shieldbalance = true
    end
  end
 
  def rewear?
    
    #Manually check for the soulmaster, try and lose him
    if @soulmaster
      send_kmuddy_command("lose soulmaster")
      @soulmaster = false
      #Stop trying to do anything else after this...
      return nil
    end

    #Go through each instance variable, and re-wear where needed
    @thefthash.each_pair do |key, value|
      #Grab the instance variable and check if it's true...
      if instance_variable_get("@#{key}balance")
        #if so... rewear and set the instance variable to false
        send_kmuddy_command("wear #{value}")
        instance_variable_set("@#{key}balance", false)
        #stop the procession of checking and wait until we regain balance again.
        return nil 
      end
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

