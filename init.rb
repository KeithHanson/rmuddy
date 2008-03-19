#!/usr/bin/env ruby
Dir[File.join(File.dirname(__FILE__), "gems", "gems", "*")].each do |gem_folder|
  $: << gem_folder + "/lib/"
end

require File.join(File.dirname(__FILE__), "connection_handler.rb")
require File.join(File.dirname(__FILE__), "receiver.rb")
require 'yaml'
require "ruby2ruby"


DEBUG = false

debug("Starting Receiver...")
receiver = Receiver.new()

debug("Starting Connection Handler")
connection_handler = ConnectionHandler.new(receiver)

connection_handler.start
debug("Connection Handler Started")