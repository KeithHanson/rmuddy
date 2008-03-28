class BasePlugin
  attr_accessor :triggers, :receiver

  def initialize(rec)
    @receiver = rec

    self.setup
  end
  
  def bar_line
    warn("=" * 80)
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
    warn("RMuddy: #{self.class.to_s} Plugin has been disabled.")
  end

  def enable
    unless @receiver.enabled_plugins.include?(self)
      @receiver.disabled_plugins.delete(self)
      @receiver.enabled_plugins << self
    end
    warn("#{self.class.to_s} Plugin has been enabled.")
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
  def blank_line
    warn("")
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

end