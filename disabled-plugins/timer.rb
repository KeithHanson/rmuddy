#Timer module for RMuddy... may very well be pulled back into core/init/baseplugin at some point... currently sitting outside for testing.


class Timer < BasePlugin
  def setup
    
  end
  
  #Use this in your timer blocks... this should be interesting.
  def timer (time_to_wait, method)
    Thread.new {
      @start_time = time.now
    }
  end
  
  def help
    warn("Dude, you don't really need help with this... it's not going to be callable via kmuddy, I don't think")
  end
  
end
