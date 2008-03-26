#Inscriber module for RMuddy triggering/aliasing system.
#Module to handle inscribing batches of tarot cards in Achaea
#Will make sure you only ever sip in between cards... still very rough
#draft.

module Inscriber
attr_accessor :number_to_inscribe
attr_accessor :type_to_inscribe
attr_accessor :inscribing


  def inscriber_setup
    warn("RMuddy Tarot Batch Inscription Module loaded (module inscriber)")
    trigger /ins (\d+) (\w+)/, :set_number_to_inscribe
    trigger /startins/, :should_we_inscribe?
    trigger /You have successfully inscribed/, :decrement_counter
    trigger /^You lack the mental resources to etch a Tarot card./, :out_of_mana!
    
    #by default, we are not, in fact, inscribing
    @inscribing = false
    @number_to_inscribe = 0
    @type_to_inscribe = 0
  end
  
  def set_number_to_inscribe (match_object )
    @number_to_inscribe = match_object[1].to_i
    @type_to_inscribe = match_object[2].to_s
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe)
    set_kmuddy_variable("type_to_inscribe", @type_to_inscribe)
  end
  
  def inscribe_tarot
    @inscribing = true
    if @character_current_mana < 350
      send_kmuddy_command("sip mana")
    end
    send_kmuddy_command("inscribe blank with $type_to_inscribe")
  end
  
  def decrement_counter
    @inscribing = false
    @number_to_inscribe -= 1
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe)
    should_we_inscribe?
  end
  
  def out_of_mana!
    @inscrbing = false
    send_kmuddy_command("sip mana")
  end
  
  def should_we_inscribe?
    if @number_to_inscribe > 0
      inscribe_tarot
    elsif @number_to_inscribe == 0
      send_kmuddy_command("ind all $type_to_inscribe")
      send_kmuddy_command("sip mana")
    end
  end
end