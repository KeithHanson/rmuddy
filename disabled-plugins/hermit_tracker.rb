#Module for tracking where you have charged Hermit tarot cards in achaea
#USAGE: /notify 4567 Hermittracker activate_hermit <tag to associate room with>
#       /notify 4567 Hermittracker fling_hermit <room-tag>
#The tracker -should- automagically keep track of which card you charged, and 
#where, and get it from your pack.
class Hermit_tracker < BasePlugin
  def setup
    @whichhermit = ''
    @key = ''
    @charginghermit = false
    warn("Loading hermit locations database")
    File.open("configs/hermithash.yaml") {|fi| @hermithash = YAML.load(fi)}
    trigger /card(\d+)\s+a tarot card inscribed with the Hermit/, :set_value
    trigger /You take the Hermit tarot and rub it vigorously on the ground/, :save_hash
    trigger /^The card begins to glow with a mystic energy/, :hermit_drop
    send_kmuddy_command("ind 50 hermit")
    warn("Hermit Tracker loaded")
  end
  
  def activate_hermit(key)
    if key == ''
      warn("You must supply a word to associate this room with!!")
    else
      warn("Ok, activating a hermit for this room")
      send_kmuddy_command("outd hermit")
      send_kmuddy_command("ii hermit")
      @key = key
      warn("Associating card #{@whichhermit} with the place name #{@key}")
      @hermithash[key] = @whichhermit
      send_kmuddy_command("activate hermit")
    end
  end
  
  def set_value(match_object )
    @whichhermit = match_object[1]
  end
  
  def save_hash
    File.open("configs/hermithash.yaml", "w") {|fi| YAML.dump(@hermithash, fi)}
    warn("Saved hermit tracker hash")
  end
  
  def fling_hermit(key)
    if key == ''
      warn("Come now, you have to tell me where to go! Specify a hermit to fling!")
    else
      send_kmuddy_command("get #{@hermithash[key]} from pack")
      send_kmuddy_command("charge hermit")
      @charginghermit = true
    end
  end
  
  def hermit_list
    @hermithash.each_key { |key| puts key }
  end
  
  def hermit_drop
    if @charginghermit
      send_kmuddy_command("fling hermit at ground")
      @charginghermit = false
      @hermithash.delete(@key.to_s)
    end
  end
end