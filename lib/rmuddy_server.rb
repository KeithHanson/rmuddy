require File.join(File.dirname(__FILE__), 'terminal_communication.rb')
require 'net/telnet'
include Net
include TerminalCommunication

class RMuddyServer
  attr_accessor :receiver
  attr_accessor :remote_address, :remote_port, :remote_session
  attr_accessor :local_port, :local_session

  def initialize(receiver)
    @sent_banner = false

    @receiver = receiver

    @remote_session = Telnet.new("Host" => "achaea.com")

    @local_session =  TCPServer.new('localhost', 4568).accept

    @receiver.remote_session = @remote_session
    @receiver.local_session = @local_session
  end

  def start
    while ((sleep 0.01) >= 0)
      result = select([@local_session, @remote_session], nil, nil)
      @receiver.communications_ready = true
      unless result[0][0].nil? && result[0][1].nil?
        result[0].each do |event_socket|
          if event_socket.object_id == @remote_session.object_id
            line = @remote_session.recvfrom(65000)[0]

            unless @sent_banner
              line = @receiver.banner + "\n\n" + line
              @sent_banner = true
            end

            @local_session.write(line)
          elsif event_socket.object_id == @local_session.object_id
            line = @local_session.recvfrom(65000)[0]
            @remote_session.write(line)
          end
        end
        result[2].each do |exception_socket|
          if exception_socket == @local_session
            puts "RMuddy Server had an exception!"
            @local_session.close
            @remote_session.close
          elsif exception_socket == @remote_session
            puts "Achaea Server had an exception!"
            @local_session.close
            @remote_session.close
          end
        end
      end
    end
  end

end