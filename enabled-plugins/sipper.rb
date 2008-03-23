#The AutoSipper. It checks to see if a certain threshold percentage is hit for
#Health and Mana, and keeps your health/mana above that percentage.
#
#You will undoubtedly need to add exception triggers in to disable sipping,
#but right now it is customized for Tarot inscribing.
module Sipper

  def sipper_enabled?
    @sipper_enabled
  end
  
  #Check to make sure we are not below our health threshold
  #We make sure to use floats! Since integers round ;)
  def health_below_threshold?
    (@character_current_health.to_f / @character_total_health.to_f) * 100 < @health_threshold_percentage
  end
  
  #Same as above
  def mana_below_threshold?
    (@character_current_mana.to_f / @character_total_mana.to_f) * 100 < @mana_threshold_percentage
  end

  def sipper_setup
    warn("RMuddy: Sipper Plugin Loaded!")
    #By default, we want to be healed ;)
    @sipper_enabled = true

    #Our health and mana thresholds
    @health_threshold_percentage = 70
    @mana_threshold_percentage = 70 
    
    #After every time the character's current stats are updated, we check to see if we should sip.
    after Character, :character_set_simple_stats, :should_i_sip?
    after Character, :character_set_extended_stats, :should_i_sip?
    
    #This group of triggers disables the sipping for various reasons.
    trigger /^Your mind feels stronger and more alert\.$/, :disable_sip
    trigger /^The elixer heals and soothes you\.$/, :disable_sip
    trigger /^What is it that you wish to drink\?$/, :disable_sip
    trigger /^You are asleep and can do nothing\./, :disable_sip
    trigger /^The elixer flows down your throat without effect/, :disable_sip
    trigger /Wisely preparing yourself beforehand/, :disable_sip
    
    #This group of triggers, substantially smaller, enables the sipping when we can :)
    trigger /^You may drink another .*$/, :enable_sip    
    trigger /You have successfully inscribed the image/, :enable_sip
  end
  
  #The heart of the plugin...
  def should_i_sip?
    #If we don't have our total scores, issue a score and allow the Character plugin to update them.
    if @character_total_mana.nil? || @character_total_health.nil?
      send_kmuddy_command("score")
    else

      #Otherwise, begin checking health and mana to see if we need to do some drinking...
      if health_below_threshold? && sipper_enabled?
        send_kmuddy_command("drink health")
        @sipper_enabled = false
      end

      if mana_below_threshold? && sipper_enabled?
        send_kmuddy_command("drink mana")
        @sipper_enabled = false
      end
    end
  end
  
  def disable_sip
    @sipper_enabled = false
  end
  
  def enable_sip
    @sipper_enabled = true
  end
end
