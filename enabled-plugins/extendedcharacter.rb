#The Character plugin tracks the stats of a character. 
#It will also track afflictions, defenses, and other states soon.
#DEMONNIC: This is an intermediary version which has been modified to track 
#endurance,willpower, and equilibrium on top of the health, mana, and balance 
#already being tracked by the original character plugin by Keith. I am not
#certain, but you may wish to only have either character.rb or 
#extendedcharacter.rb active at any given time
module Extendedcharacter
  #setup the common variables for stats and state
  #attr_accessor provides us with methods and instance variables of the same name
  #demonnic: I changed the declarations to be structured by stat, as opposed to 
  #demonnic: currents and totals on one line. will make changes later easier,
  #demonnic: I think.
  
  attr_accessor :character_current_health, :character_total_health
  attr_accessor :character_current_mana, :character_total_mana
  attr_accessor :character_current_endurance, :character_total_endurance
  attr_accessor :character_current_willpower, :character_total_willpower
  attr_accessor :character_status
  attr_accessor :character_balanced
  attr_accessor :character_has_equilibrium
  
  def character_setup
    warn("RMuddy: Character Plugin Loaded!")
    #By default, we are assumed to be balanced and to have equilibrium
    @character_balanced = true
    @character_has_equilibrium = true

    #trigger off of seeing the current prompt.
    #You might need to customize this for yourself!
    #demonnic: now triggering off of CONFIG PROMPT FULL for achaea
    #trigger /^(\d+)h, (\d+)m\s.*/, :character_set_current_stats
    trigger /^(\d+)h, (\d+)m, (\d+)e, (\d+)w (\w+)-/ :character_set_current_stats
    #Trigger off of when we use the SCORE command.
    trigger /Health:\s*(\d+)\s*\/\s*(\d+)/, :character_set_total_health
    trigger /Mana:\s*(\d+)\s*\/\s*(\d+)/, :character_set_total_mana
    trigger /Willpower:\s*(\d+)\s*\/\s*(\d+)/, :character_set_total_willpower
    trigger /Endurance:\s*(\d+)\s*\/\s*(\d+)/, :character_set_total_endurance

    #set the balance when it returns. demonnic:tagged it to beginning and end 
    #demonnic: line so that it can't be broken by even sloppy illusions
    trigger /^You have recovered balance on all limbs.$/, :character_is_balanced
    
    #demonnic: set the equilibrium when it returns
    trigger /^You have recovered equilibrium.$/, :character_has_equilibrium

    #We use the prompt to tell us when we are unbalanced.
    #demonnic: so we put all that with the -other- prompt trigger... DRY
    #trigger /^\d+h, \d+m\se-/, :character_is_unbalanced

    #If for some reason we don't catch being unbalanced from the prompt...
    #We KNOW we are unbalanced from an attack.
    #demonnic: I'm not sure this is necessary... and it seems like it could end
    #demonnic: up leading to a LOT of code. commenting out for now; however,
    #demonnic: I am leaving the character_is_balanced et. al. for use in other 
    #demonnic: scripts.
    #trigger /You reach out and bop/, :character_is_unbalanced
  end
  
  #using the matches that come in, we set our stats and communicate them.
  def character_set_current_stats(match_object )
    @character_current_health = match_object[1].to_i
    @character_current_mana = match_object[2].to_i
    @character_current_endurance = match_object[3].to_i
    @character_current_willpower = match_object[4].to_i
    @character_status = match_object[5].to_s
    @character_balanced = @character_status.include? "x"
    @character_has_equilibrium = @character_status.include? "e"
    debug("Character: Loaded Current Stats")
    
    set_kmuddy_variable("character_current_health", @character_current_health)
    set_kmuddy_variable("character_current_mana", @character_current_mana)
    set_kmuddy_variable("character_current_endurance", @character_current_endurance)
    set_kmuddy_variable("character_current_willpower", @character_current_willpower)
    set_kmuddy_variable("character_balanced", @character_balanced)
    set_kmuddy_variable("character_has_equilibrium", @character_has_equilibrium)
  end
  
  #This happens when a SCORE is issued.
  #demonnic:or it did, anyways. I now have this being handled seperately for each stat,
  #demonnic:this way, it can track each one on its own and it isn't tied to just SCORE
  #demonnic:but could be seen using qsc also
  #def character_set_total_stats(match_object)
  #  @character_total_health = match_object[1].to_i
  #  @character_total_mana = match_object[2].to_i
  #  debug("Character: Loaded Total Stats")
    
  #  set_kmuddy_variable("character_total_health", @character_total_health)
  #  set_kmuddy_variable("character_total_mana", @character_total_mana)
  #end
  
  def character_set_total_health(match_object )
    @character_total_health = match_object[2].to_i
    @character_current_health = match_obect[1].to_i
  end
  
  def character_set_total_mana(match_object )
    @character_total_mana = match_object[2].to_i
    @character_current_mana = match_obect[1].to_i
  end
  
  def character_set_total_endurance(match_object )
    @character_total_endurance = match_object[2].to_i
    @character_current_endurance = match_obect[1].to_i
  end
  
  def character_set_total_willpower(match_object )
    @character_total_willpower = match_object[2].to_i
    @character_current_willpower = match_obect[1].to_i
  end

  def character_is_balanced
    @character_balanced = true
  end

  def character_is_unbalanced
    @character_balanced = false
  end
  
  def character_has_equilibrium
    @character_has_equilibrium = true
  end
  
  def character_lost_equilibrium
    @character_has_equilibrium = false
  end
  
end

debug("Character: Character file required.")