module Sipper
  
  
  def sipper_enabled?
    @sipper_enabled
  end
  
  def health_below_threshold?
    (@character_current_health.to_f / @character_total_health.to_f) * 100 < @health_threshold_percentage
  end
  
  def mana_below_threshold?
    (@character_current_mana.to_f / @character_total_mana.to_f) * 100 < @mana_threshold_percentage
  end
  
  def sipper_setup
    @sipper_enabled = true

    @health_threshold_percentage = 70
    @mana_threshold_percentage = 70 
    
    after Character, :character_set_current_stats, :should_i_sip?
    
    trigger /^Your mind feels stronger and more alert\.$/, :disable_sip
    trigger /^The elixer heals and soothes you\.$/, :disable_sip
    trigger /^What is it that you wish to drink\?$/, :disable_sip
    trigger /^You are asleep and can do nothing\./, :disable_sip
    trigger /^The elixer flows down your throat without effect/, :disable_sip
    trigger /Wisely preparing yourself beforehand/, :disable_sip
    
    trigger /^You may drink another .*$/, :enable_sip    
    trigger /You have successfully inscribed the image/, :enable_sip
  end
  
  def should_i_sip?
    if @character_total_mana.nil? || @character_total_health.nil?
      send_kmuddy_command("score")
    else
      if health_below_threshold? && sipper_enabled?
        send_kmuddy_command("drink health")
      end

      if mana_below_threshold? && sipper_enabled?
        send_kmuddy_command("drink mana")
      end
    end
  end
  
  def disable_sip(match_object)
    @sipper_enabled = false
  end
  
  def enable_sip(match_object)
    @sipper_enabled = true
  end
end
