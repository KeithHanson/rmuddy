class Receiver
  
  attr_accessor :varsock, :matches, :setups
  
  debug("Receiver: Loading Files...")
  
  #Load All Plugins
  Dir[File.join(File.dirname(__FILE__), "enabled-plugins", "*")].each do |file|
    debug("Receiver: Found #{file}")
    require file
    include module_eval(File.basename(file, ".rb").capitalize)
  end
  
  def initialize
    @triggers = {}
    @setups = []
    
    Dir[File.join(File.dirname(__FILE__), "enabled-plugins", "*")].each do |file|
      @setups << File.basename(file, ".rb") + "_setup"
    end
    
    @setups.each {|setup_string| send(setup_string.to_sym)}
  end

  def receive(text)
    @triggers.each_pair do |regex, method|
      debug("Testing #{regex} against line: #{text}")
      match = regex.match(text)
      unless match.nil?
        send(method.to_sym, match)
      else
        debug("No match!")
      end
    end
  end
  
  def trigger(regex, method)
    @triggers[regex] = method
  end
  
  def set_kmuddy_variable(variable_name, variable_value)
    @varsock.set(variable_name, variable_value)
  end
  
  def get_kmuddy_variable(variable_name)
    @varsock.get(variable_name)
  end
  
  def send_kmuddy_command(command_text)
    @varsock.command(command_text)
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

 