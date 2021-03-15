require "gtk3"
require_relative '../Puzzle01/rfid'

@message ="Please, login with your university card"
# Initial code without using classes
rf = Rfid.new

def scan_tag(rf, info_label)
  thr = Thread.new {
    uid =  rf.read_uid
    puts "Tag detected: " + uid
    info_label.set_markup("uid: " + uid)
  }
end

# Widget definition:
window = Gtk::Window.new("PBE project")
window.border_width = 10
window.title = "rfid_gtk.rb"

info_label = Gtk::Label.new(@message)

clear_button = Gtk::Button.new("Clear")

layoutBox = Gtk::Box.new(:vertical,10)
layoutBox.pack_start(info_label)
layoutBox.pack_start(clear_button)


# Signal detection section:
clear_button.signal_connect("clicked") do
  info_label.set_markup(@message)
  scan_tag(rf, info_label)
end

window.signal_connect('destroy') { Gtk.main_quit }


# Run Application
window.add(layoutBox)
window.show_all
scan_tag(rf, info_label)
Gtk.main