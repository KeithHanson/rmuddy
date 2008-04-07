#Ok, combining the hermit tracker with auto-charger/flinger and the mass inscriber... take one 
#THIS IS NOT FOOLPROOF... DON'T BE A FOOL!
#That having been said, I plan to make it foolproof at some point...
 

class Tarot < BasePlugin
  #set up our variables, etc.
  def setup
    #setup triggers here
    trigger /^The card begins to glow with a mystic energy./, :charged
    trigger /^Rubbing your fingers briskly on the card, you charge it with necessary energy./, :charging
    trigger /^The mystic glow on the Tarot card fades./, :uncharged
    trigger /^You have recovered equilibrium.$/, :put_away_hermit
    trigger /card(\d+)\s+a tarot card inscribed with the Hermit/, :set_value
    trigger /You take the Hermit tarot and rub it vigorously on the ground/, :save_hash
    trigger /You have successfully inscribed/, :decrement_counter #we did it!
    trigger /^You lack the mental resources to etch a Tarot card./, :out_of_mana! #oops, ran out of mana
    trigger /^None of your decks contain a card with the image of (.+)/, :aint_got_it
    after Character, :is_balanced, :fling_card
    after Character, :gained_equilibrium, :fling_card
    #setup variables here... comment specific bits if necessary for sanity
    
    #because I like some things to be stored as variables for easy changing later... formatting sheit mostly
    @whichhermit = ''
    @key = ''
    @formatlength = 80
    @formatpad = (@formatlength / 3)
    @resethash = {"Location" => "card number"}
    
    #by default, we are not, in fact, inscribing, activating, or charging any cards
    @tarotcards = %w(sun emperor magician priestess fool chariot hermit empress lovers hierophant hangedman tower wheel creator justice star aeon lust universe devil moon death)
    @groundonly = %w(chariot hermit universe)
    @charginghermit = false
    @paused = false
    @batch_total = 0
    @inscribing = false
    @number_to_inscribe = 0
    @type_to_inscribe = ""
    @card_to_fling = ''
    @target = ''
    @tarotcards.each{ |key| warn("Full Tarot list: #{key}") }
    @groundonly.each {|key| warn("Ground Only: #{key}")}
    #do any other actual setup work here
    warn("Loading hermit locations database")
    unless File.open("configs/hermithash.yaml") {|fi| @hermithash = YAML.load(fi)}
      warn("Failed to find and load the hermit database. You need to have hermithash.yaml in the configs directory")
    else
      warn("Hermit database loaded")
    end
    send_kmuddy_command("ind 50 hermit")
  end
  
  #this is the receptacle into which your commands for non-hermit flinging should go
  def tarot_card (card = '', target = 'ground')
    #determine what card to outd, outd it, then charge it
    warn("Ok, we're gonna use #{card} on #{target}")
    @card_to_fling = card.downcase
    @target = target.downcase
    if @tarotcards.include?(@card_to_fling)
      warn("It's a real tarot card!")
      if @groundonly.include?(@card_to_fling)
        @target = "ground"
        send_kmuddy_command("outd #{@card_to_fling}")
        send_kmuddy_command("charge #{@card_to_fling}")
      else
        send_kmuddy_command("outd #{@card_to_fling}")
        send_kmuddy_command("charge #{@card_to_fling}")
      end
    else
      warn("Ok... I need a real tarot card, and who/what to fling it at... if it's the ground, you may omit the target")
    end
  end
  
  #cuz we might want some help for the tarot module
  def help (topic = '')
    if topic == ''
      warn("Specificy a topic: inscribe, hermit, or use")
    elsif topic.downcase == "inscribe"
      warn("To inscribe, /notify 4567 Tarot mass_inscribe <number to inscribe> <type of tarot to inscribe>")
      warn("Then /notify 4567 Tarot begin_inscribing to actually begin the inscription process")
      warn("/notify 4567 (un)pause_inscription will (un)pause the batch inscription process")
      warn("I doubt it has to be said, but just in case, that's pause_inscript or unpause_inscription, with no ()")
      blank_line
    elsif topic.downcase == "hermit"
      warn("For hermit tracking, you can use /notify 4567 Tarot activate_hermit <what you want to call this place>")
      warn("this will outd a hermit, check its card number, then activate it and put it away, storing it in our database")
      warn("/notify 4567 Tarot fling_hermit <whereyawannago> will then grab the appropriate hermit (based on the same name you gave it when you did activate_hermit)")
      warn("charge the hermit, and then fling it. It will at this point delete it from the database of hermit locations")
      warn("/notify 4567 Tarot del_hash <which room to delete> will remove the room you tell it to remove from the hermit locations database")
      warn("/notify 4567 Tarot reset_hash will wipe the entire database, if all of your hermits have decayed")
      blank_line
    elsif topic.downcase == "use"
      warn("this is very basic tarot card usage here... but essentially you would")
      warn("/notify 4567 Tarot tarot_card <which card to throw> <who/what to throw it at>")
      warn("it should then outd the card, charge the card, and after the card is charged fling it the next time you regain equilibrium/balance")
      blank_line
    else
      warn("Please specify a valid topic: inscribe, hermit, or use")
    end
    
  end
  
  #So we know it's charged, and can fling that biatch
  def charged
    @charging = false
    @charged = true
    fling_card
  end
  def fling_card
    #fling the card as commanded... and do the correct one, at whom, and do it
    if @card_to_fling != '' && @target != '' && plugins[Character].balanced && plugins[Character].has_equilibrium && @charged
      send_kmuddy_command("fling #{@card_to_fling} at #{@target}")
      @card_to_fling = ''
      @target = ''
      uncharged
      if @card_to_fling.downcase == 'hermit'
        @charginghermit = false
        @hermithash.delete(@key.to_s)
      end
    end
   end
  
  #in case we need it later
  def charging
    @charging = true
  end
  
  def uncharged
    @charged = false
  end
  
  #so... you tried to outd a card you don't have...
  def aint_got_it(match_object = '')
    warn("You tried to get a #{match_object} but you don't have one, man.")
    @card_to_fling = ''
    @target = ''
  end
  
  #imported from the mass inscriber
  def mass_inscribe(number_to_inscribe, type_to_inscribe)
    @number_to_inscribe = number_to_inscribe.to_i
    @type_to_inscribe = type_to_inscribe.to_s
    @batch_total = number_to_inscribe.to_i
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe)
    set_kmuddy_variable("type_to_inscribe", @type_to_inscribe)
    warn("Inscriber Plugin: Ready to inscribe #{@number_to_inscribe} #{@type_to_inscribe}")
    warn("Use begin_inscribing to start.")
  end

  #begin the inscription process
  def begin_inscribing
    inscribe_tarot
  end
  
  #here's how we actually inscribe the bloody cards
  def inscribe_tarot   
    disabled_plugins[Sipper].enable unless disabled_plugins[Sipper].nil?
    plugins[Sipper].should_i_sip? #check to see if we need mana before we inscribe
    plugins[Sipper].disable #then disable the sipper so as not to kill our inscribe
    send_kmuddy_command("inscribe blank with #{@type_to_inscribe}")  #and actually inscribe
  end
  
  #lower the counter, so we inscribe the correct # of cards
  def decrement_counter  
    @number_to_inscribe -= 1 #decrement counter
    set_kmuddy_variable("number_to_inscribe", @number_to_inscribe) #let kmuddy know
    should_we_inscribe?      #check if we should do another!
  end
   
  #pretty obvious
  def out_of_mana! 
    @inscribing = false  #if we're out of mana, we're not inscribing
    plugins[Sipper].enable
    send_kmuddy_command("sip mana")  #so we need to sip some mana
  end
  
  #so we can stop in the middle of stuff
  def pause_inscription
    @paused = true
  end
  
  #so we can continue when we're done flapping our gums
  def unpause_inscription
    @paused = false
    inscribe_tarot
  end
  
  #test if we should inscribe
  def should_we_inscribe?  
    if @number_to_inscribe > 0  && !@paused #if we still have inscription to do and we're not paused
      inscribe_tarot   #then inscribe
    elsif @number_to_inscribe == 0  #otherwise, if there are 0 left to do
      disabled_plugins[Sipper].enable unless disabled_plugins[Sipper].nil?
      send_kmuddy_command("ind #{@batch_total} #{@type_to_inscribe}")  #put the cards away
      plugins[Sipper].should_i_sip? #check if we need to sip 
    end
  end
  
  #imported from the hermit tracker... might as well keep it all in one, right?
  #
  #the code which associates a specific hermit card with the room you're in. ONE WORD KEYS ONLY
  def activate_hermit(key = '')
    if key == ''
      warn("You must supply a word to associate this room with!!")
    else
      @key = key
      warn("Ok, activating a hermit for this room")
      send_kmuddy_command("outd hermit")
      send_kmuddy_command("ii hermit")
    end

  end
  
  #this grabs the hermit's unique ID from "ii hermit" so it can be stored in the hash
  def set_value(match_object )
    @whichhermit = match_object[1]
    associate_hermit
  end
  
  #the code which actually creates the association
  def associate_hermit
      warn("Associating card #{@whichhermit} with the place name #{@key}")
      @hermithash[@key] = @whichhermit
      send_kmuddy_command("activate hermit")
      @activatinghermit = true
  end
  
  #saves your hash of hermitty type locations
  def save_hash
    File.open("configs/hermithash.yaml", "w") {|fi| YAML.dump(@hermithash, fi)}
    warn("Saved hermit tracker hash")
  end
  
  #accepts the command to grab hermit for room <key> and begin the charging/flinging process
  def fling_hermit(key = '')
    @key = key
    if key == ''
      warn("Come now, you have to tell me where to go! Specify a hermit to fling!")
    else
      send_kmuddy_command("get #{@hermithash[key]} from pack")
      send_kmuddy_command("charge hermit")
      @charginghermit = true
    end
  end
  
  #put the sucker away once it is activated
  def put_away_hermit
    if @activatinghermit
      send_kmuddy_command("Put hermit in pack")
      @activatinghermit = false
    end
  end
  
  #to manually remove a key from the hash
  def del_hash (key = '')
    if key == ''
      warn("You must specify the room tag you wish to remove from the database")
    else
      warn("deleting #{key} from the hermit locations database")
      @hermithash.delete(key.to_s)
      save_hash
    end
  end
  
  #nicely formatted list of all the hermits the tracker is tracking
  def hermit_list
    warn("Hermits currently in database")
    @output = "Location".ljust(@formatpad) + @hermithash["Location"].rjust(@formatpad)
    warn(@output)
    @hermithash.each_key { |key| 
     unless key == "Location" 
       @output = "#{key.to_s}".ljust(@formatpad) + @hermithash[key].to_s.rjust(@formatpad)
       warn(@output)
     end
    }
  end
  
  #been gone awhile, hermits turned to dust? Well... reset the hash
  def reset_hash
    warn("Resetting hermit database... all hermit location is now kaput")
    @hermithash = @resethash
    save_hash
  end
  
  #actually does the work of dropping/flinging the hermit to begint the teleportation
  def hermit_drop
    if @charginghermit
      send_kmuddy_command("fling hermit at ground")
      @charginghermit = false
      @hermithash.delete(@key.to_s)
    end
  end

end


  
