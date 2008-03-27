#Inscriber module for RMuddy triggering/aliasing system.
#Module to handle inscribing batches of tarot cards in Achaea
#Will make sure you only ever sip in between cards... still very rough
#draft.

module Inscriber
#we'll setup some accessor methods, weee
attr_accessor :number_to_inscribe
attr_accessor :type_to_inscribe
attr_accessor :inscribing


  def inscriber_setup
    #Let the user know it's loading... 
    warn("RMuddy: Tarot Batch Inscription Module loading")
    
    #setup our triggers for commands... will be deprecated when /notify works
    trigger /ins (\d+) (\w+)/, :set_number_to_inscribe  #command to set params
    trigger /startins/, :should_we_inscribe?            #command to go!
    trigger /You have successfully inscribed/, :decrement_counter #we did it!
    trigger /^You lack the mental resources to etch a Tarot card./, :out_of_mana! #oops, ran out of mana
    
    #by default, we are not, in fact, inscribing
    @inscribing = false
    @number_to_inscribe = 0
    @type_to_inscribe = 0
  end
  
  def test_this
    #added to test /notify with a working module (stupid hermittracker)
    warn("testing...")
  end
  
  def set_number_to_inscribe (match_object )   #so we need to actually set the params
    @number_to_inscribe = match_object[1].to_i #so we match to the trigger
    @type_to_inscribe = match_object[2].to_s   #and do it
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe)  #and push back to kmuddy
    set_kmuddy_variable("type_to_inscribe", @type_to_inscribe)
  end
  
  def inscribe_tarot   #here's how we actually inscribe the bloody cards
    @inscribing = true #let everything know we are currently inscribing
    self::Sipper.should_i_sip? #check to see if we need mana before we inscribe
    self::Sipper.disable_sip   #then disable the sipper so as not to kill our inscribe
    send_kmuddy_command("inscribe blank with $type_to_inscribe")  #and actually inscribe
  end
  
  def decrement_counter  #lower the counter, so we inscribe the correct # of cards
    @inscribing = false  #if it triggered into this, we've just finished one
    @number_to_inscribe -= 1 #decrement counter
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe) #let kmuddy know
    should_we_inscribe?      #check if we should do another!
  end
  
  def out_of_mana!  #pretty obvious
    @inscribing = false  #if we're out of mana, we're not inscribing
    send_kmuddy_command("sip mana")  #so we need to sip some mana
  end
  
  def should_we_inscribe?  #test if we should inscribe
    if @number_to_inscribe > 0  #if we still have inscription to do
      inscribe_tarot   #then inscribe
    elsif @number_to_inscribe == 0  #otherwise, if there are 0 left to do
      send_kmuddy_command("ind 50 $type_to_inscribe")  #put the cards away
      self::Sipper.should_i_sip? #check if we need to sip 
    end
  end
end