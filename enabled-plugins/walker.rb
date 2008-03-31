#The Walker is a taaaaad bit more complex than the other plugins.
#The main reason being that we need to use multi-threading to make timers work.
#Essentially, we set our character down on a mono-rail of directions they should go through,
#and from there let the room ratter do it's work. Every time we hit, see, or do anything to a rat,
#we want to reset the timers again. Once the timer is up, move forward.
class Walker < BasePlugin
  attr_accessor :opposite_directions, :last_timer, :lost_or_not, :seconds_to_wait
  attr_accessor :rail_position, :current_rail, :current_thread, :ratter_rail, :auto_walk_enabled
  attr_accessor :back_tracking

  def setup
    warn("***The Auto Walker will fully automate your ratting and is considered ILLEGAL by Achaea.***")
    warn("***Use at your own risk!***")
 
    #When we backtrack along the rail, we'll need these.
    @opposite_directions = { "n" => "s", "s" => "n", "e" => "w", "w" => "e", "ne" => "sw", "sw" => "ne", "nw" => "se", "se" => "nw", "in" => "out", "out" => "in", "u" => "d", "d" => "u"} 

    #last_timer is essentially the last time the timer was started.
    @last_timer = Time.now
    
    #lost or not? Well, let's see
    @lost_or_not = 0
    #This is to seed the random number generator
    #So we don't get duplicate sequences 
    srand = Time.now.to_i

    #This is where we define, how many seconds to wait, randomly 0-10
    @seconds_to_wait = rand(10)

    #default values. This is the position on our mono-rail, so to speak.
    @rail_position = 0
    @current_rail = 0

    #The current thread that is doing the moving around. We'll have a reference to it here
    #So we can kill it if need be.
    @current_thread = nil

    #The path to walk, the rail of our mono... or something of that nature ;)
    #It is an array of arrays. First array holds all paths, inner array holds movements.
    @ratter_rail = [
                      %w(n n ne e n e ne e n ne e se e ne se ne n n e ne e n ne e se se e s s sw s s w sw nw w w sw w w nw w s s sw s s s sw w w w s w w nw sw nw nw n n),
                      %w(n n ne e n e ne e n nw w nw sw nw n n ne se e ne e se ne n e e s se s s s se s s s s sw s s s sw w w w s w w nw sw nw nw n n)
                         ]
                           

    #defaults
    @auto_walk_enabled = false
    @backtracking = false

    #Since we moved and see a new room, we increment the rail position.
    trigger /You see exits leading/, :increment_rail_position
    trigger /You see a single exit/, :increment_rail_position

    #The only time we ever care about moving too fast is when we're back-tracking.
    #So when we see this message, we didn't hit our next room and need to try again.
    trigger /Now now, don't be so hasty!/, :backtrack

    #The skip room method is used to skip places where it's considered rude to rat.
    #It also tries to skip places with people in them...
    trigger /The Crossroads\./, :skip_room
    trigger /is here\./, :skip_room

    trigger /There is no exit in that direction/, :lost!
    
    #After doing any thing that would cause us to do something to a rat, reset the timers.
    after Ratter, :should_i_attack_rat?, :reset_rail_timer

    #Enable and disable the auto walker with these two after filters.
    after Ratter, :enable_ratter, :enable_walker
    after Ratter, :disable_ratter, :disable_walker

    #This mother thread keeps track of the sub thread that does the timing.
    Thread.new do 
      while true do
        sleep 0.03

        if @auto_walk_enabled

          @last_timer = Time.now
          @seconds_to_wait = rand(10) + 10

          @current_thread = Thread.new do 
            while @last_timer + @seconds_to_wait >= Time.now do
              sleep 1
            end
            
            #If we can walk, walk!
            if plugins[Character].balanced && plugins[Character].has_equilibrium && @auto_walk_enabled
              send_kmuddy_command("#{@ratter_rail[@current_rail][@rail_position]}")
            end
          end

          #Pauses mother thread until sub thread is finished.
          @current_thread.join

        end
      end
    end
  end

  def enable_walker
    warn("Auto Walker turned on. (Used with the Room Ratter.)")
    @auto_walk_enabled = true

    reset_rail_timer
  end

  def disable_walker
    warn("Auto Walker turned off. (Used with the Room Ratter.)")
    @auto_walk_enabled = false
    kill_thread
    @backtracking = true
    unless @rail_position <= 0
      @rail_position -= 1 
      send_kmuddy_command("#{@opposite_directions[@ratter_rail[@current_rail][@rail_position]]}")
    end
  end

  def skip_room
    if @auto_walk_enabled
      send_kmuddy_command("#{@ratter_rail[@current_rail][@rail_position + 1]}")
    end
  end
  
  #def misguided
  # @lost_or_not += 1
  # if @lost_or_not == 1
  #   @rail_position -= 2
  # elsif @lost_or_not <3
  #   @rail_position -= 1
  # else
  #   lost!
  # end
  # end


  def lost!
    if @auto_walk_enabled == true
      warn("Auto Walker is LOST! Disabling.")
      @auto_walk_enabled = false
    end
  end

  def increment_rail_position
    @lost_or_not = 0
    if plugins[Ratter].ratter_enabled && @auto_walk_enabled
      if @rail_position + 1 < @ratter_rail[@current_rail].length
        @rail_position += 1 
      else
        @rail_position = 0

        if @current_rail + 1 < @ratter_rail.length
          @current_rail += 1
           warn "Auto Walker: Finished moving along current Rail. Loading Next Rail."
        else
          @current_rail = 0
          warn "Auto Walker: Finished moving along last rail. Loading First Rail."
        end
      end
    end

    backtrack
  end

  def backtrack
    if @backtracking
      warn("We're backtracking")
      if @rail_position > 0
        warn "Auto Walker: Backtracking #{@rail_position} steps."
      else
        warn "Auto Walker: Finished Backtracking."
        disable_walker
      end
      if @rail_position > 0
        @rail_position -= 1
        sleep 0.5
        send_kmuddy_command("#{@opposite_directions[@ratter_rail[@current_rail][@rail_position]]}")
      else
        @backtracking = false

        if @current_rail + 1 < @ratter_rail.length
          @current_rail += 1
          warn "Auto Walker: Finished moving along current Rail. Loading Next Rail."
        else
          @current_rail = 0
          warn "Auto Walker: Finished moving along last rail. Loading First Rail."
        end
      end
    end
  end

  def reset_rail_timer
    @last_timer = Time.now
    @seconds_to_wait = rand(10) + 5
    #warn("Timers Reset")
    #warn("Last Timer: #{@last_timer}")
    #warn("Seconds to wait: #{@seconds_to_wait}")
  end

  def kill_thread
    unless @current_thread.nil?
      @current_thread.kill
      @current_thread = nil
    end
  end

end 