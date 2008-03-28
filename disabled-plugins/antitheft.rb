# Plugin for RMuddy. Should handle basic anti-theft, configuration will be in anti_theft.yaml

class Antitheft < BasePlugin
  #setup method for the plugin.. triggers, var. init and stuff goes here
  def setup
    trigger /^(\w+) snaps his fingers in front of you/, :hypnosis
    trigger /^A soulmaster entity lets loose a horrible scream as a dark stream of primal chaos flows from it and into your very being/, :lose_soulmaster
    trigger /You get \d+ gold sovereigns from \w+/, :put_gold_away
    trigger /^You remove a canvas backpack/, :rewear_pack
    trigger /^You remove a suit of scale mail/, :rewear_armor
    
    unless (File.open("configs/anti_theft.yaml") {|fi| @thefthash = YAML.load(fi)}) 
      warn("No configuration file found... you must have the configuration file anti_theft.yaml in the configs directory")
    end
  end
  
  def help
    warn("OK, you asked for it. You must setup the YAML file. It has a format. Each thing should be on a seperate line")
    warn("The format is... on separate lines, mind you, with nothing in front of it")
    warn("item: \"<fully described item, with number here>\"")
    blank_line
    warn("example:")
    warn("pack: \"pack296008\"")
    blank_line
    warn("You can use \"/notify 4567 Antitheft set_pack pack296008\" to accomplish the same result as the line above")
    warn("and this module should have been packaged with a template antitheft.yaml file with it")
    blank_line
    warn("Items which can be set in the yaml file. There is a set_item method for each of these. IE set_pack, set_armor ad nauseum")
    @thefthash.each_key { |key| warn("#{key}") }
    blank_line
    warn("If you've got alternate gear... say, a sailor's kitbag, or what have")
    warn("you, you'll need to modify the triggers in the antitheft.rb file to match the appropriate message")
  end
  
end

