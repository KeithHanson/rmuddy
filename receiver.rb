class Receiver
  
  attr_accessor :varsock, :matches, :setups, :queue
  
  debug("Receiver: Loading Files...")
  
  #Load All Plugins
  Dir[File.join(File.dirname(__FILE__), "enabled-plugins", "*.rb")].each do |file|
    debug("Receiver: Found #{file}")
    require file
    include module_eval(File.basename(file, ".rb").capitalize)
  end
  
  def initialize
    warn("RMuddy: System Loading...")
    @triggers = {}
    @setups = []
    @queue = []
    
    Dir[File.join(File.dirname(__FILE__), "enabled-plugins", "*.rb")].each do |file|
      @setups << File.basename(file, ".rb") + "_setup"
    end
    
    @setups.each {|setup_string| send(setup_string.to_sym)}
    
    Thread.new do
      while true do
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

    warn("RMuddy: System Ready!")
  end

  def receive(text)
    @triggers.each_pair do |regex, method|
      debug("Testing #{regex} against line: #{text}")
      match = regex.match(text)
      unless match.nil?
        unless match[1].nil?
          send(method.to_sym, match)
        else
          send(method.to_sym)
        end
      else
        debug("No match!")
      end
    end
  end

  def command(text)
    method_and_args = text.split(" ")
    klass = module_eval(method_and_args[0])
    method_sym = method_and_args[1].to_sym
    args = method_and_args[2..-1]
    
    debug("RMuddy: Sending to Plugin #{klass.name.to_s}::#{method_sym.to_s} with arguments #{args.join(", ")}")
    self::klass.send(method_sym, *args)
  end
  
  def trigger(regex, method)
    @triggers[regex] = method
  end
  
  def set_kmuddy_variable(variable_name, variable_value)
    @queue << ["set_var", variable_name, variable_value]
  end
  
  def get_kmuddy_variable(variable_name)
    @varsock.get(variable_name)
  end
  
  def send_kmuddy_command(command_text)
    @queue << ["send_command", command_text]
  end
  
  def before(module_name, method_symbol, hook_symbol)
    method = Ruby2Ruby.translate(module_name, method_symbol.to_sym)
    
    new_method = method.split("\n")
    new_method.insert(1, "send(:#{hook_symbol.to_s})")
    
    module_name.module_eval(new_method.join("\n"))
  end
  
  def after(module_name, method_symbol, hook_symbol)
    method = Ruby2Ruby.translate(module_name, method_symbol.to_sym)
    
    new_method = method.split("\n")
    
    new_method.insert(-2, "send(:#{hook_symbol.to_s})")
    
    module_name.module_eval(new_method.join("\n"))
  end
  
  def to_s
    "Receiver Loaded"
  end
end

 