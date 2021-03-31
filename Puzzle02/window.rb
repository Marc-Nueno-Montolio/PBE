require "gtk3"
require 'json'
require_relative 'header'

class Window < Gtk::Window
  $config = JSON.parse(File.read("config.json"))
  @button_box = Gtk::ButtonBox.new(:horizontal)
  @@label = Gtk::Label.new($config['welcome-message'])
  @@label.set_name("mainLabel")
  @@clear_button = Gtk::Button.new(:label => "CLEAR")
  @@header = Header.new()

  def initialize
    super
    $cssProvider = Gtk::CssProvider.new
    Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, $cssProvider, Gtk::StyleProvider::PRIORITY_APPLICATION)
    update_label($config['welcome-message'], "blue")

    set_default_size 600, 100
    self.titlebar = @@header
    @@clear_button.signal_connect "clicked" do
      if $config['debug'] == "true"
        puts "Cleared"
      end
      update_label($config['welcome-message'], $config['default-bg'])
    end

    vbox = Gtk::Box.new(:vertical, 10)
    vbox.add(@@label)
    vbox.add(@@clear_button)

    add(vbox)
  end

  def update_label(text, background)
    @@label.set_markup(text)
    if background == nil
      background = "blue"
    end
    $cssProvider.load(data: <<-CSS)
              label#mainLabel{
                  font-size: 20px;
                  background-color: #{background};
                  color: white;
                  padding: 10px;
                  margin: 10px;
                  border-radius: 10px;
              }
    CSS

  end

end