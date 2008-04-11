#!/usr/bin/env ruby

DEBUG = false

Dir[File.join(File.dirname(__FILE__), "gems", "gems", "*")].each do |gem_folder|
  $: << gem_folder + "/lib/"
end

require File.join(File.dirname(__FILE__), "lib/rmuddy_server.rb")
require File.join(File.dirname(__FILE__), "lib/base_plugin.rb")
require File.join(File.dirname(__FILE__), "lib/receiver.rb")
require 'yaml'
require "ruby2ruby"

receiver = Receiver.new()

output "\n\n#{ANSI["lightgreen"]}RMuddy is Online.#{ANSI["reset"]}"
server = RMuddyServer.new(receiver)
server.start