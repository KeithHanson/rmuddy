require File.join(File.dirname(__FILE__), "kmuddy", 'kmuddy.rb')
require File.join(File.dirname(__FILE__), "kmuddy", 'eventserver.rb')
require File.join(File.dirname(__FILE__), "kmuddy", 'variablesock.rb')

include KMuddy

class ConnectionHandler
  def initialize(receiver)
    $server_port = 4567
    debug("ConnectionHandler--Server Port: #{$server_port}")

    @evserver = EventServer.new($server_port)
    @varsock =  VariableSock.new()
    @threads = [ ]
    
    @receiver = receiver
    @receiver.varsock = @varsock
    debug("ConnectionHandler--Receiver: #{@receiver}")
  end
  
  def start
    @threads << Thread.new {
      while line = STDIN.gets.chomp
        # Normally one would parse the line of text from the server here.
        # Instead, I demonstrate the 'set' method of the VariableSock.
        # Check your variables in KMuddy after you receive text from the
        # mud.
        @receiver.receive(line)
      end
    }

   threads << Thread.new {
      while (event = evserver.accept)
          line = event.gets.chomp
          debug("Received Line: #{line}") unless line.empty?
          exit(0) if line == "quit"
          #varsock.command(line)
          @receiver.command(line)
          event.close
      end
}

    @threads.each { |task| task.join }
  end
end