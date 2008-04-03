#Inscriber module for RMuddy triggering/aliasing system.
#Module to handle inscribing batches of tarot cards in Achaea
#Will make sure you only ever sip in between cards... still very rough
#draft.

class Inscriber < BasePlugin
#we'll setup some accessor methods, weee
attr_accessor :number_to_inscribe
attr_accessor :type_to_inscribe
attr_accessor :inscribing


  def setup
    #setup our triggers for commands... will be deprecated when /notify works
    trigger /You have successfully inscribed/, :decrement_counter #we did it!
    trigger /^You lack the mental resources to etch a Tarot card./, :out_of_mana! #oops, ran out of mana
    
    #by default, we are not, in fact, inscribing
    @paused = false
    @batch_total = 0
    @inscribing = false
    @number_to_inscribe = 0
    @type_to_inscribe = ""
  end
  
  def mass_inscribe(number_to_inscribe, type_to_inscribe)
    @number_to_inscribe = number_to_inscribe.to_i
    @type_to_inscribe = type_to_inscribe.to_s
    @batch_total = number_to_inscribe.to_i
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe)
    set_kmuddy_variable("type_to_inscribe", @type_to_inscribe)
    warn("Inscriber Plugin: Ready to inscribe #{@number_to_inscribe} #{@type_to_inscribe}")
    warn("Use begin_inscribing to start.")
  end

  def begin_inscribing
    inscribe_tarot
  end

  def inscribe_tarot   #here's how we actually inscribe the bloody cards
    disabled_plugins[Sipper].enable unless disabled_plugins[Sipper].nil?
    plugins[Sipper].should_i_sip? #check to see if we need mana before we inscribe
    plugins[Sipper].disable #then disable the sipper so as not to kill our inscribe
    send_kmuddy_command("inscribe blank with #{@type_to_inscribe}")  #and actually inscribe
  end
  
  def decrement_counter  #lower the counter, so we inscribe the correct # of cards
    @number_to_inscribe -= 1 #decrement counter
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe) #let kmuddy know
    should_we_inscribe?      #check if we should do another!
  end
  
  def out_of_mana!  #pretty obvious
    @inscribing = false  #if we're out of mana, we're not inscribing
    plugins[Sipper].enable
    send_kmuddy_command("sip mana")  #so we need to sip some mana
  end
  
  def pause_inscription
    @paused = true
  end
  
  def unpause_inscription
    @paused = false
    inscribe_tarot
  end
  
  def should_we_inscribe?  #test if we should inscribe
    if @number_to_inscribe > 0  && !@paused #if we still have inscription to do and we're not paused
      inscribe_tarot   #then inscribe
    elsif @number_to_inscribe == 0  #otherwise, if there are 0 left to do
      disabled_plugins[Sipper].enable unless disabled_plugins[Sipper].nil?
      send_kmuddy_command("ind #{@batch_total} #{@type_to_inscribe}")  #put the cards away
      plugins[Sipper].should_i_sip? #check if we need to sip 
    end
  end
end