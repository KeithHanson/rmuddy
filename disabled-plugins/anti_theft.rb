# Plugin for RMuddy. Should handle basic anti-theft, configuration will be in anti_theft.yaml

class Anti_theft < BasePlugin
  #setup method for the plugin.. triggers, var. init and stuff goes here
  def setup
    trigger /^(\w+) snaps his fingers in front of you/, :hypnosis
    trigger /^A soulmaster entity lets loose a horrible scream as a dark stream of primal chaos flows from it and into your very being/, :lose_soulmaster
    trigger /You get \d+ gold sovereigns from \w+/, :put_gold_away
    trigger /^You remove a canvas backpack/, :rewear_pack
    trigger /^You remove a suit of scale mail/, :rewear_armor
    File.open("configs/anti_theft.yaml") {|fi| @thefthash = YAML.load(fi)}
  end
end

