#Timer module for RMuddy... may very well be pulled back into core/init/baseplugin at some point... currently sitting outside for testing.


class Timer < BasePlugin
  
  def setup
    
  end
  
  #Use this in your timer blocks... this should be interesting.
  def timer (time_to_wait, method)
    Thread.new do 
      sleep time_to_wait #this will be in seconds, though fractions will do
      self.send(method.to_sym)
    end
  end

  #this one repeats every time_to_wait seconds
  def time_block
    start_time = Time.now
    Thread.new { yield }
    Time.now - start_time
  end

  def heartbeat(time_to_wait)
    while true do
      time_spent = time_block { yield }
      sleep(time_to_wait - time_spent) if time_spent < time_to_wait
    end
  end
  
  def help
    warn("Dude, you don't really need help with this... it's not going to be callable via kmuddy, I don't think")
    warn("And even if it -is-... it's pretty straightforward... heartbeat(time in seconds) { stuff to do }")
    warn("The time can be in decimal, so you can do heartbeat(0.030) {cure} and it will call your 'cure' method every 30 milliseconds")
    warn("similarly, you can do") 
    warn("timer 0.3 has_balance")
    warn("And it will execute the has_balance method 300 milliseconds after it executes")
    warn("So, I suppose, you could manually inject this kind of stuff by doing")
    warn("/notify 4567 Timer timer 1 plugins[Sipper].should_i_sip?")
    warn("To have it check in 1 second if you should sip... ")
  end
  
end
