#The Ratter plugin is, essentially, a one room auto-ratter.
#It keeps track of the rats in your inventory, as well as how much you have earned so far.
#It will send these variables on to kmuddy as the following variables, 
#so you can make status variables or guages or what have you
#   current_rat_count (Total rats collected so far)
#   total_rat_money (Total money you will earn after selling the rats)

#This has currently been customized for the Jester class and for ratting in Hashani.
#Further configurability to come.
class Ratter < BasePlugin

  attr_accessor :ratter_enabled, :balance_user, :attack_command, :available_rats
  attr_accessor :inventory_rats, :rat_prices, :total_rat_money

  def setup
    #By default, we will disable the ratter.
    @ratter_enabled = false

    #This determines if we're a balance user or an equilibrium user...
    @balance_user = false
    
    #What do we do when we want them dead?
    @attack_command = "warp rat"

    #Set the current room's rats to 0
    @available_rats = 0

    #Set the inventory's rats to 0
    @inventory_rats = 0

    #Ratting prices taken from HELP RATTING
    @rat_prices = {"baby rat" => 7, "young rat" => 14, "rat" => 21, "old rat" => 28, "black rat" => 35}

    #Total money collected so far.
    @total_rat_money = 0

    #This group of triggers alerts the ratter that a rat is available in the room.
    trigger /With a squeak, an*\s*\w* rat darts into the room, looking about wildly./, :rat_is_available
    trigger /Your eyes are drawn to an*\s*\w* rat that darts suddenly into view./, :rat_is_available
    trigger /An*\s*\w* rat noses its way cautiously out of the shadows./, :rat_is_available
    trigger /An*\s*\w* rat wanders into view, nosing about for food./, :rat_is_available
    
    #Identifies when a rat has been killed, incrementing counters and such.
    trigger /You have slain an*\s(.*\s*rat), retrieving the corpse./, :killed_rat

    #Identifies when a rat has left the room.
    trigger /An*\s*\w* rat wanders back into its warren where you may not follow./, :rat_is_unavailable
    trigger /With a flick of its small whiskers, an*\s*\w* rat dashes out of view./, :rat_is_unavailable
    trigger /An*\s*\w* rat darts into the shadows and disappears./, :rat_is_unavailable
    
    #Identify when there WAS a rat, but there no longer is cuz someone else using RMuddy ninja'd it
    trigger /I do not recognise anything called that here./, :no_rats!
    trigger /Ahh, I am truly sorry, but I do not see anyone by that name here./, :no_rats!
    trigger /Nothing can be seen here by that name./, :no_rats!
    trigger /You detect nothing here by that name./, :no_rats!
    trigger /You cannot see that being here./, :no_rats!

    #disable and enable the scripts with "rats" in the mud.
    trigger /You will now notice the movement of rats\. Happy hunting\!/, :enable_ratter
    trigger /You will no longer take notice of the movement of rats\./, :disable_ratter
    
    #sell your rats when you come into the room Liirup is in!
    trigger /Liirup the Placid stands here/, :sell_rats_hashan
    trigger /The Ratman stands here quietly/, :sell_rats_ashtan
    #Reset the money after selling to the ratter in hashan. .. Or Ashtan, now
    trigger /Liirup squeals with delight/, :reset_money
    trigger /The ratman thanks you as you hand over/, :reset_money

    trigger /You see exits/, :reset_available_rats
    trigger /You see a single exit/, :reset_available_rats

    #After we gain balance, we need to decide if we should attack again or not.
    after Character, :set_simple_stats, :should_i_attack_rat?
    after Character, :set_extended_stats, :should_i_attack_rat?
  end

  def ratter_enabled?
    @ratter_enabled
  end
  
  def self_rats_ashtan
    if @ratter_enabled
      send_kmuddy_command("Sell rats to Ratman")
    end
  end

  def rat_available?
    @available_rats > 0
  end

  def rat_is_available
    #increment the available rats in the room by one.
    @available_rats += 1
  end

  def rat_is_unavailable
    #decrement by one unless we're already at 0 for some reason.
    @available_rats -= 1 unless @available_rats <= 0
  end

  def killed_rat(match_object)
    #decrement by one unless we're already at 0 for some reason
    @available_rats -= 1 unless @available_rats <= 0

    #add the rat to our inventory rats
    @inventory_rats += 1

    #take the match for the type of rat that we killed, look up it's price, and add it to the money
    @total_rat_money += @rat_prices[match_object[1]]

    #send updated stats
    set_kmuddy_variable("current_rat_count", @inventory_rats)
    set_kmuddy_variable("total_rat_money", @total_rat_money)
  end
  
  def no_rats!
    @available_rats = 0
  end

  def enable_ratter
    warn("Room Ratter Turned On.")
    @ratter_enabled = true
  end

  def disable_ratter
    warn("Room Ratter Turned Off.")
    @ratter_enabled = false
  end

  #reset the stats and send them
  def reset_money
    @total_rat_money = 0

    set_kmuddy_variable("total_rat_money", 0)

    @inventory_rats = 0

    set_kmuddy_variable("current_rat_count", 0)
    send_kmuddy_command("put sovereigns in pack")
  end
  
  def reset_available_rats
    @available_rats = 0
  end
  
  def sell_rats_hashan
    if @ratter_enabled
      send_kmuddy_command("Sell rats to Liirup")
    end
  end
  
  #Decide whether or not we should attack a rat and do so if we can.
  def should_i_attack_rat?
    if @balance_user
      if rat_available? && plugins[Character].balanced
        send_kmuddy_command(@attack_command)
      end
    else
      if rat_available? && plugins[Character].has_equilibrium
        send_kmuddy_command(@attack_command)
      end
    end
  end
end