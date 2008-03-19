module Character
  attr_accessor :character_current_health, :character_current_mana
  attr_accessor :character_total_health, :character_total_mana
  attr_accessor :character_balanced
  
  def character_setup
    
    @character_balanced = true

    trigger /^(\d+)h, (\d+)m\s.*/, :character_set_current_stats
    
    trigger /^Health: \d*\/(\d*)\s\sMana: \d*\/(\d*)$/, :character_set_total_stats

    trigger /You have recovered balance on all limbs./, :character_is_balanced

    trigger /^\d+h, \d+m\se-/, :character_is_unbalanced

    trigger /You reach out and bop/, :character_is_unbalanced
  end
  
  def character_set_current_stats(match_object )
    @character_current_health = match_object[1].to_i
    @character_current_mana = match_object[2].to_i
    debug("Character: Loaded Current Stats")
    
    set_kmuddy_variable("character_current_health", @character_current_health)
    set_kmuddy_variable("character_current_mana", @character_current_mana)
  end
  
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