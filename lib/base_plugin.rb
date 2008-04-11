class BasePlugin
  attr_accessor :triggers, :receiver

  def initialize(rec)
    @receiver = rec

    self.setup
  end
    
  def plugins
    @receiver.plugins
  end

  def disabled_plugins
    @receiver.disabled_plugins
  end

  def disable
    unless @receiver.disabled_plugins.include?(self)
      @receiver.enabled_plugins.delete(self)
      @receiver.disabled_plugins << self
    end
  end

  def enable
    unless @receiver.enabled_plugins.include?(self)
      @receiver.disabled_plugins.delete(self)
      @receiver.enabled_plugins << self
    end
  end

  def help
    warn("That plugin's author has not created a help for you!")
  end

  def trigger(regex, method)
    @triggers ||= {}
    @triggers[regex] = method
  end

  def set_kmuddy_variable(variable_name, variable_value)
    @receiver.queue << ["set_var", variable_name, variable_value]
  end
  
  def get_kmuddy_variable(variable_name)
    @receiver.varsock.get(variable_name)
  end
  
  def send_kmuddy_command(command_text)
    @receiver.queue << ["send_command", command_text]
  end
  
  def before(module_name, method_symbol, hook_symbol)
    method = Ruby2Ruby.translate(module_name, method_symbol.to_sym)
    
    new_method = method.split("\n")
    new_method.insert(1, "plugins[#{self.class}].send(:#{hook_symbol.to_s}) if plugins[#{self.class}] ")
    
    module_name.module_eval(new_method.join("\n"))
  end
  
  def after(module_name, method_symbol, hook_symbol)
    method = Ruby2Ruby.translate(module_name, method_symbol.to_sym)
    
    new_method = method.split("\n")
    
    new_method.insert(-2, "plugins[#{self.class}].send(:#{hook_symbol.to_s}) if plugins[#{self.class}] ")
    
    module_name.module_eval(new_method.join("\n"))
  end
  
  #Use this in your timer blocks... this should be interesting.
  def simple_timer (time_to_wait, method)
    Thread.new do 
      sleep time_to_wait #this will be in seconds, though fractions will do
      self.send(method.to_sym)
    end
  end

  #Method to allow sending a command to another plugin.
  def plugin_timer(time_to_wait, plugin, method)
    Thread.new do
      sleep time_to_wait
      if plugin.class?(Class)
        plugins[plugin].send(method.to_sym)
      else
        plugin.send(method.to_sym)
      end
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

end