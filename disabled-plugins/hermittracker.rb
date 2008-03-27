#Module for tracking where you have charged Hermit tarot cards in achaea
#USAGE: /notify 4567 Hermittracker activate_hermit <word to associate room with>
#       /notify 4567 Hermittracker fling_hermit <word you tagged the room you want to go to with>
#The tracker -should- automagically keep track of which card you charged, and
#where, and get it from your pack.
module Hermittracker

  def hermittracker_setup
    
    #Setup our hermit tracker module... by default, there is no hermit, no key, 
    #we are not charging the tarot
    @whichhermit = ''
    @key = ''
    @charginghermit = false
    
    #Let the user know we're loading the hash
    warn("Rmuddy: Loading hermit locations database")
    file = File.open("configs/hermithash.yaml")
    @hermithash = YAML.load(file)
    file.close
    hermit_list
    warn("Rmuddy: Hash loaded, database open, hermit away")
    
    #trigger set, in RMuddy DSL, for when you check the hermit you are
    #activating, when you've activated it, and to check when you charge a card
    #if you've told RMuddy you're wanting to use a hermit
    trigger /card(\d+)\s+a tarot card inscribed with the Hermit/, :set_hermit_value
    trigger /You take the Hermit tarot and rub it vigorously on the ground/, :save_hermit_hash
    trigger /^The card begins to glow with a mystic energy/, :hermit_drop
    
    #Put all the hermits you happen to have in your inventory in a deck... this
    #keeps the trigger for checking which hermit is being activated working
    #cleanly
    send_kmuddy_command("ind 50 hermit")
    
    #all done! let the user know it's loaded up
    warn("Rmuddy: Hermit Tracker loaded")
  end

  def test_this
    #added to help test /notify capability of RMuddy
    warn("Test passed!")
  end

  def activate_hermit(key)
    if key == ''  #If you don't provide us with what you want to call this room
      warn("You must supply a word to associate this room with!!") #we tell you
    else                                                           #about it
      warn("Ok, activating a hermit for this room") #otherwise, we let you know
      send_kmuddy_command("outd hermit")            #take a card out
      send_kmuddy_command("ii hermit")              #inspect it
      @key = key                                    #set @key to equal the key
      warn("Associating card @whichhermit with the place name @key") #notify
      @hermithash[key] = @whichhermit   #store the key=>card#### pair
      send_kmuddy_command("activate hermit") #activate the hermit card
    end
  end

  def set_hermit_value (match_object )  #this is to set @whichhermit when it is
    @whichhermit = match_object[1]      #inspected via ii, above
  end

  def save_hermit_hash     #save our hash to the yaml file
    File.open("configs/hermithash.yaml", "w") {|f| YAML.dump(@hermithash, f)}
    warn("Saved hermit tracker hash") #and let user know about it
  end

  def fling_hermit(key)  #ok, we need to skedaddle
    if key == ''  #again, if you don't tell us where to go... 
      warn("Come now, you have to tell me where to go! Specify a hermit to fling!")
    else     #otherwise
      send_kmuddy_command("get @hermithash[key] from pac")  #get the proper card
      send_kmuddy_command("charge hermit")  #and charge it
      @charginghermit = true  #let the script know we're trying to use a hermit card
    end
  end

  def hermit_list  #print out a list of keys from our hash... fairly simple
    @hermithash.each_key { |key| warn("key") }
  end

  def hermit_drop      #ACTUALLY fling the hermit card
    if @charginghermit #but ONLY if we're actually charging a HERMIT
      send_kmuddy_command("fling hermit at ground")  #ok.. so do it
      @charginghermit = false   #and now we're not charging a hermit
      @hermithash.delete("@key") #and we no longer have that card
    end
  end

end