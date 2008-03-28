#The Character plugin tracks the stats of a character. 
#It will also track afflictions, defenses, and other states soon.
class Character < BasePlugin
  #setup the common variables for stats and state
  #attr_accessor provides us with methods and instance variables of the same name
  attr_accessor :current_health, :current_mana
  attr_accessor :total_health, :total_mana
  attr_accessor :current_endurance, :total_endurance
  attr_accessor :current_willpower, :total_willpower
  attr_accessor :balanced
  attr_accessor :status
  attr_accessor :has_equilibrium
  
  def setup
    #By default, we are assumed to be balanced and to have equilibrium.
    @balanced = true
    @has_equilibrium = true
    @using_extended_status = false

    #trigger off of seeing the current prompt.
    #You might need to customize this for yourself!
    trigger /^(\d+)h, (\d+)m  (\w+)-/, :set_simple_stats
    trigger /^(\d+)h, (\d+)m, (\d+)e, (\d+)w (\w+)-/, :set_extended_stats
      
    #Trigger off of when we use the SCORE command.
    trigger /Health:\s*(\d+)\s*\/\s*(\d+)/, :set_total_health
    trigger /Mana:\s*(\d+)\s*\/\s*(\d+)/, :set_total_mana
    trigger /Willpower:\s*(\d+)\s*\/\s*(\d+)/, :set_total_willpower
    trigger /Endurance:\s*(\d+)\s*\/\s*(\d+)/, :set_total_endurance
    

    #set the balance when it returns.
    #trigger /^You have recovered balance on all limbs.$/, :is_balanced

    #demonnic: set the equilibrium when it returns
    #trigger /^You have recovered equilibrium.$/, :gained_equilibrium

    #We use the prompt to tell us when we are unbalanced.
    #trigger /^\d+h, \d+m\se-/, :is_unbalanced

    #If for some reason we don't catch being unbalanced from the prompt...
    #We KNOW we are unbalanced from an attack.
    #trigger /You reach out and bop/, :is_unbalanced
  end
  
  #using the matches that come in, we set our stats and communicate them.
  def set_simple_stats(match_object)
    unless @using_extended_stats == true
      @current_health = match_object[1].to_i
      @current_mana = match_object[2].to_i
      @balanced = match_object[3].include?("x")
      @has_equilibrium = match_object[3].include?("e")
      #Because it will be helpful to keep using is_balanced and gained_equilibrium
      if match_object[3].include?("x")
        is_balanced
      elsif match_object[3].include?("e")
        gained_equilibrium
      end

      debug("Character: Loaded Current Stats")
      debug("Character: Sending Current Stats")
      set_kmuddy_variable("character_current_health", @current_health)
      set_kmuddy_variable("character_current_mana", @current_mana)
      set_kmuddy_variable("character_balanced", @balanced)
      set_kmuddy_variable("character_has_equilibrium", @has_equilibrium)

      debug("Character: Sent Current Stats")

      unless @total_health
        send_kmuddy_command("qsc")
      end
    end
  end

  def set_extended_stats(match_object)
    @current_health = match_object[1].to_i
    @current_mana = match_object[2].to_i
    @current_endurance = match_object[3].to_i
    @current_willpower = match_object[4].to_i
    @balanced = match_object[5].include?("x")
    @has_equilibrium = match_object[5].include?("e")

    debug("Character: Loaded Current Stats")
    debug("Character: Sending Current Stats")

    set_kmuddy_variable("character_current_health", @current_health)
    set_kmuddy_variable("character_current_mana", @current_mana)
    set_kmuddy_variable("character_current_endurance", @current_endurance)
    set_kmuddy_variable("character_current_willpower", @current_willpower)
    set_kmuddy_variable("character_balanced", @balanced)
    set_kmuddy_variable("character_has_equilibrium", @has_equilibrium)

    debug("Character: Sent Current Stats")

    @using_extended_stats = true

    unless @total_health
      send_kmuddy_command("qsc")
    end
  end
  
   def set_total_health(match_object )
    @total_health = match_object[2].to_i
    @current_health = match_object[1].to_i
    set_kmuddy_variable("character_current_health", @current_health)
    set_kmuddy_variable("character_total_health", @total_health)
  end
  
  def set_total_mana(match_object )
    @total_mana = match_object[2].to_i
    @current_mana = match_object[1].to_i
    set_kmuddy_variable("character_current_mana", @current_mana)
    set_kmuddy_variable("character_total_mana", @total_mana)
  end
  
  def set_total_endurance(match_object )
    @total_endurance = match_object[2].to_i
    @current_endurance = match_object[1].to_i
    set_kmuddy_variable("character_current_endurance", @current_endurance)
    set_kmuddy_variable("character_total_endurance", @total_endurance)
  end
  
  def set_total_willpower(match_object )
    @total_willpower = match_object[2].to_i
    @current_willpower = match_object[1].to_i
    set_kmuddy_variable("character_current_willpower", @current_willpower)
    set_kmuddy_variable("character_total_willpower", @total_willpower)
  end

  def is_balanced
    @balanced = true
  end

  def is_unbalanced
    @balanced = false
  end

  def gained_equilibrium
    @has_equilibrium = true
  end
  
  def lost_equilibrium
    @has_equilibrium = false
  end
  
end