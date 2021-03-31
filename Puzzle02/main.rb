#!/usr/bin/env ruby
=begin
  This program is an improved graphical version of the rfid.rb script
  Author: Marc Nueno Montolio marcnueno@gmail.com
  Version: 1.0
=end
require 'gtk3'
require "thread"
require 'json'
require_relative '../Puzzle01/rfid'
require_relative 'window'

$config = JSON.parse(File.read("config.json"))

rf = Rfid.new()

win = Window.new()
win.show_all

thr = Thread.new() {
  if $config['debug'] == "true"
    puts "Scanning..."
  end
  while true do
    uid = "uid: " + rf.read_uid().to_s
    sleep(1)
    puts uid
    win.update_label(uid, $config['success-bg'])
  end
}

win.show_all.signal_connect("delete_event") do
  puts "Exiting..."
  Gtk.main_quit
  Thread.list.each { |t| t.kill if t != Thread.main }
end


Gtk.main
thr.join

