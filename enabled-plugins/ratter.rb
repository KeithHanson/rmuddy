module Ratter
  def ratter_setup
    @ratter_enabled = false
    @available_rats = 0
    @inventory_rats = 0

    @rat_prices = {"baby rat" => 7, "young rat" => 14, "rat" => 21, "old rat" => 28, "black rat" => 35}

    @total_rat_money = 0

    trigger /With a squeak, an*\s*\w* rat darts into the room, looking about wildly./, :rat_is_available
    trigger /Your eyes are drawn to an*\s*\w* rat that darts suddenly into view./, :rat_is_available
    trigger /An*\s*\w* rat noses its way cautiously out of the shadows./, :rat_is_available
    trigger /An*\s*\w* rat wanders into view, nosing about for food./, :rat_is_available
    
    trigger /You have slain an*\s(.*\s*rat), retrieving the corpse./, :killed_rat

    trigger /An*\s*\w* rat wanders back into its warren where you may not follow./, :rat_is_unavailable
    trigger /With a flick of its small whiskers, an*\s*\w* rat dashes out of view./, :rat_is_unavailable
    trigger /An*\s*\w* rat darts into the shadows and disappears./, :rat_is_unavailable

    trigger /You will now notice the movement of rats\. Happy hunting\!/, :enable_ratter
    trigger /You will no longer take notice of the movement of rats\./, :disable_ratter
    
    trigger /Liirup squeals with delight/, :reset_money
    
    after Character, :character_is_balanced, :should_i_attack_rat?
  end

  def ratter_enabled?
    @ratter_enabled
  end

  def rat_available?
    @available_rats > 0
  end

  def rat_is_available
    @available_rats += 1

    if rat_available? && @character_balanced
      send_kmuddy_command("bop rat")
    end
  end

  def rat_is_unavailable
    @available_rats -= 1 unless @available_rats <= 0
  end

  def killed_rat(match_object)
    @available_rats -= 1 unless @available_rats <= 0

    @inventory_rats += 1

    @total_rat_money += @rat_prices[match_object[1]]

    set_kmuddy_variable("current_rat_count", @inventory_rats)
    set_kmuddy_variable("total_rat_money", @total_rat_money)
  end

  def enable_ratter
    @ratter_enabled = true
  end

  def disable_ratter
    @ratter_enabled = false
  end

  def reset_money
    @total_rat_money = 0

    set_kmuddy_variable("total_rat_money", 0)

    @inventory_rats = 0

    set_kmuddy_variable("current_rat_count", 0)
  end

  def should_i_attack_rat?
    if rat_available? && @character_balanced
      send_kmuddy_command("bop rat")
    end
  end
end