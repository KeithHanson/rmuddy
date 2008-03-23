#The Character plugin tracks the stats of a character. 
#It will also track afflictions, defenses, and other states soon.
module Character
  #setup the common variables for stats and state
  #attr_accessor provides us with methods and instance variables of the same name
  attr_accessor :character_current_health, :character_current_mana
  attr_accessor :character_total_health, :character_total_mana
  attr_accessor :character_balanced
  
  def character_setup
    warn("RMuddy: Character Plugin Loaded!")
    #By default, we are assumed to be balanced.
    @character_balanced = true

    #trigger off of seeing the current prompt.
    #You might need to customize this for yourself!
    trigger /^(\d+)h, (\d+)m\s.*/, :character_set_current_stats
      
    #Trigger off of when we use the SCORE command.
    trigger /^Health: \d*\/(\d*)\s\sMana: \d*\/(\d*)$/, :character_set_total_stats

    #set the balance when it returns.
    trigger /You have recovered balance on all limbs./, :character_is_balanced

    #We use the prompt to tell us when we are unbalanced.
    trigger /^\d+h, \d+m\se-/, :character_is_unbalanced

    #If for some reason we don't catch being unbalanced from the prompt...
    #We KNOW we are unbalanced from an attack.
    trigger /You reach out and bop/, :character_is_unbalanced
  end
  
  #using the matches that come in, we set our stats and communicate them.
  def character_set_current_stats(match_object )
    @character_current_health = match_object[1].to_i
    @character_current_mana = match_object[2].to_i
    debug("Character: Loaded Current Stats")
    
    set_kmuddy_variable("character_current_health", @character_current_health)
    set_kmuddy_variable("character_current_mana", @character_current_mana)
  end
  
  #This happens when a SCORE is issued.
  def character_set_total_stats(match_object)
    @character_total_health = match_object[1].to_i
    @character_total_mana = match_object[2].to_i
    debug("Character: Loaded Total Stats")
    
    set_kmuddy_variable("character_total_health", @character_total_health)
    set_kmuddy_variable("character_total_mana", @character_total_mana)
  end

  def character_is_balanced
    @character_balanced = true
  end

  def character_is_unbalanced
    @character_balanced = false
  end
  
end

debug("Character: Character file required.")