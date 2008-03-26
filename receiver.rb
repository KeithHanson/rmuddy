class Receiver
  
  attr_accessor :varsock, :enabled_plugins, :disabled_plugins, :queue
  
  def plugins
    @enabled_plugins
  end

  debug("Receiver: Loading Files...")

  #Load All Plugins
  Dir[File.join(File.dirname(__FILE__), "enabled-plugins", "*.rb")].each do |file|
    debug("Receiver: Found #{file}")
    require file
    attr_accessor File.basename(file, ".rb").to_sym
  end
  
  def initialize
    warn("RMuddy: System Loading...")
    @queue = []
    @enabled_plugins = []

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
    
    Dir[File.join(File.dirname(__FILE__), "enabled-plugins", "*.rb")].each do |file|
      basename = File.basename(file, ".rb")
      class_string = basename.split("_").each{|part| part.capitalize!}.join("")

      instantiated_class = Object.module_eval(class_string).new(self)
      instantiated_class.enable
    end
    
    Thread.new do
      while true do
        sleep 0.1
        if @queue.length > 0
          element = @queue.shift
          case element[0]
          when "set_var"
            @varsock.set(element[1], element[2])
          when "send_command"
            @varsock.command(element[1])
          end
        end
      end
    end

    warn("=" * 80)
    warn("You may send commands to RMuddy's plugins like so:")
    warn("/notify 4567 PluginName action_name arg1 arg2 arg3")
    warn("=" * 80)
    warn("You may ask a plugin for help by doing:")
    warn("/notify 4567 PluginName help")
    warn("=" * 80)
    warn("RMuddy: System Ready!")
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