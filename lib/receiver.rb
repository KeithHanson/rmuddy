class Receiver
  
  attr_accessor :varsock, :enabled_plugins, :disabled_plugins, :queue
  attr_accessor :local_session, :remote_session, :communications_ready

  def echo(text)
    if communications_ready
      @local_session.write(text)
    end
  end

  def send_command(text)
    if communications_ready
      @remote_session.write(text)
    end
  end

  def plugins
    @enabled_plugins
  end

  def banner
    <<-EOF
#{ANSI["lightred"]}
     _____ ____ _____
    /    /      \\    \\
  /____ /_________\\____\\
  \\    \\          /    /
    \\  \\        /  /
        \\ \\    / /
          \\ \\/ /
            \\/
#{ANSI["reset"]}
      #{ANSI["lightred"]}RMuddy v0.9#{ANSI["reset"]}
   A Pure Ruby System
        For MUDs

#{ANSI["red"]}**RMuddy Will Begin It's Initialization Now.**#{ANSI["reset"]}
EOF
  end

  #Load All Plugins
  Dir[File.join(File.dirname(__FILE__), "../enabled-plugins", "*.rb")].each do |file|
    require file
    attr_accessor File.basename(file, ".rb").to_sym
  end
  
  def initialize
    

    @queue = []
    @enabled_plugins = []
    @communication_ready = false
    output banner

    class << @enabled_plugins
      alias_method :original_indexer, :[]

      def [](arg)
        if arg.is_a?(Class)
          each do |plugin|
            if plugin.is_a?(arg)
              return plugin
            end
          end

          return nil
        else
          original_indexer(arg)
        end
      end
    end
 
    @disabled_plugins = []

    class << @disabled_plugins
      alias_method :original_indexer, :[]

      def [](arg)
        if arg.is_a?(Class)
          each do |plugin|
            if plugin.is_a?(arg)
              return plugin
            end
          end

          return nil
        else
          original_indexer(arg)
        end
      end
    end
    
    Dir[File.join(File.dirname(__FILE__), "../enabled-plugins", "*.rb")].each do |file|
      basename = File.basename(file, ".rb")
      class_string = basename.split("_").each{|part| part.capitalize!}.join("")
      output "#{ANSI["lightred"]}**RMuddy found and loaded plugin: #{ANSI["lightgreen"]}#{class_string}#{ANSI["lightred"]}**#{ANSI["reset"]}"
      instantiated_class = Object.module_eval(class_string).new(self)
      instantiated_class.enable
    end

#     bar_line
#     warn("You may send commands to RMuddy's plugins like so:")
#     warn("/notify 4567 PluginName action_name arg1 arg2 arg3")
#     bar_line
#     warn("You may ask a plugin for help by doing:")
#     warn("/notify 4567 PluginName help")
#     bar_line
  end
  
  def bar_line
    warn("=" * 80)
  end

  def receive(text)
    @enabled_plugins.each do |klass|
      klass.triggers.each_pair do |regex, method|
        debug("Testing Plugin: #{klass.to_s}| Regex: #{regex} against line: #{text}")
        match = regex.match(text)
        unless match.nil?
          debug("Match!")
          unless match[1].nil?
            klass.send(method.to_sym, match)
          else
            klass.send(method.to_sym)
          end
        else
          debug("No match!")
        end
      end
    end
  end

  def command(text)
    debug("RMuddy received notify command: #{text} ")
    method_and_args = text.split(" ")

    klass = Object.module_eval("#{method_and_args[0]}")
  
    method_sym = method_and_args[1].to_sym
    args = method_and_args[2..-1]
    unless method_sym == :enable
      @enabled_plugins.each do |plugin|
        if plugin.is_a?(klass)
          unless args.empty?
            plugin.send(method_sym, *args)
          else
            plugin.send(method_sym)
          end #args check
        end #check the class of the plugin
      end #loop through enabled plugins
    else # Check to see if it's an enable command
      @disabled_plugins.each do |plugin|
        if plugin.is_a?(klass)
          plugin.send(:enable)
        end #check for class of the plugin
      end #looping through the disabled plugins
    end # end of check for :enable
  end #end of Command method.

end