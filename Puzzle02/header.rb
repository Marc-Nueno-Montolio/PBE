require 'json'

class Header < Gtk::HeaderBar

  @@button = Gtk::Button.new()
  icon = Gio::ThemedIcon.new("applications-system-symbolic")
  image = Gtk::Image.new(:icon => icon, :size => :button)
  @@button.add(image)

  def initialize
    super()
    self.title = $config['window-title']
    self.pack_start(@@button)

    @@button.signal_connect("clicked") do
      dialog = Gtk::Dialog.new
      dialog.title = "Configuració de l'aplicació"
      dialog.set_default_size(300, 300)
      dialog.child.add(Gtk::Label.new("PBE Reader Config Options"))

      box = Gtk::Box.new(:horizontal, 5)
      button1 = Gtk::CheckButton.new("Dark Theme")
      dialog.child.add(button1)
      button2 = Gtk::CheckButton.new("Sound on Scan")
      dialog.child.add(button2)
      button3 = Gtk::CheckButton.new("show_quit_button")
      dialog.child.add(button3)
      button4 = Gtk::CheckButton.new("show_options")

      button1.signal_connect('toggled') {
        active = button1.active? ? true : false
        if active
          Gtk::Settings.default.gtk_application_prefer_dark_theme = true

        else
          Gtk::Settings.default.gtk_application_prefer_dark_theme = false

        end
      }

      button2.signal_connect('toggled') {
        active = button2.active? ? true : false
        if active
          puts "Sound Activated"
        else
          puts "Sound Deactivated"
        end
      }

      button3.signal_connect('toggled') {
        active = button3.active? ? true : false
        if active
          self.show_close_button = true
        else
          self.show_close_button = false
        end
      }

      button4.signal_connect('toggled') {
        active = button4.active? ? true : false
        if active
          self.pack_start(@@button)
        else
          self.remove(@@button)
        end
      }
      dialog.child.add(button4)

      box = Gtk::Box.new(:horizontal, 5)
      box.add(Gtk::Label.new("Default Background:"))
      color1 = Gtk::Entry.new()
      color1.text = $config['default-bg']
      btn = Gtk::Button.new(:label => "OK")
      box.add(color1)
      box.add(btn)
      btn.signal_connect("clicked") {
        $config['default-bg'] = color1.text
        File.write('config.json', $config.to_json, nil, mode: 'w')
      }
      dialog.child.add(box)

      box = Gtk::Box.new(:horizontal, 5)
      box.add(Gtk::Label.new("Success Background:"))
      color2 = Gtk::Entry.new()
      color2.text = $config['success-bg']
      btn = Gtk::Button.new(:label => "OK")
      box.add(color2)
      box.add(btn)
      btn.signal_connect("clicked") {
        $config['success-bg'] = color2.text
        File.write('config.json', $config.to_json, nil, mode: 'w')
      }
      dialog.child.add(box)

      dialog.show_all
    end

  end

  def show_quit_button(show = true)
    self.show_close_button = show
  end

end

