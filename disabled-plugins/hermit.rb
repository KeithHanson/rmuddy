#Module for tracking where you have charged Hermit tarot cards in achaea
#USAGE: /notify 4567 Hermit activate_hermit <tag to associate room with>
#       /notify 4567 Hermit fling_hermit <room-tag>
#The tracker -should- automagically keep track of which card you charged, and 
#where, and get it from your pack.
class Hermit < BasePlugin
  
  def setup
    @whichhermit = ''
    @key = ''
    @formatlength = 80
    @formatpad = (@formatlength / 3)
    @charginghermit = false
    @resethash = {"Location" => "card number"}
    warn("Loading hermit locations database")
    File.open("configs/hermithash.yaml") {|fi| @hermithash = YAML.load(fi)}
    trigger /^You have recovered equilibrium.$/, :put_away_hermit
    trigger /card(\d+)\s+a tarot card inscribed with the Hermit/, :set_value
    trigger /You take the Hermit tarot and rub it vigorously on the ground/, :save_hash
    trigger /^The card begins to glow with a mystic energy/, :hermit_drop
    send_kmuddy_command("ind 50 hermit")
    warn("Hermit Tracker loaded")
  end
  
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
  
  def set_value(match_object )
    @whichhermit = match_object[1]
    associate_hermit
  end
  
  def associate_hermit
      warn("Associating card #{@whichhermit} with the place name #{@key}")
      @hermithash[@key] = @whichhermit
      send_kmuddy_command("activate hermit")
      @activatinghermit = true
  end
  
  def save_hash
    File.open("configs/hermithash.yaml", "w") {|fi| YAML.dump(@hermithash, fi)}
    warn("Saved hermit tracker hash")
  end
  
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
  
  def put_away_hermit
    if @activatinghermit
      send_kmuddy_command("Put hermit in pack")
      @activatinghermit = false
    end
  end
  
  def del_hash (key = '')
    if key == ''
      warn("You must specify the room tag you wish to remove from the database")
    else
      warn("deleting #{key} from the hermit locations database")
      @hermithash.delete(key.to_s)
      save_hash
    end
  end
  
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
  
  def reset_hash
    warn("Resetting hermit database... all hermit location is now kaput")
    @hermithash = @resethash
    save_hash
  end
  
  def hermit_drop
    if @charginghermit
      send_kmuddy_command("fling hermit at ground")
      @charginghermit = false
      @hermithash.delete(@key.to_s)
    end
  end
end
