require "gtk3"

win = Gtk::Window.new
win.signal_connect "destroy" do
  Gtk.main_quit
end

mybutton = Gtk::Button.new(:label => "Does nothing")
mybutton.margin = 10
css_provider = Gtk::CssProvider.new
css_provider.load(data: <<-CSS)
button {
  background-image: image(cyan);
}

button:hover {
  background-image: image(green);
}

button:active {
  background-image: image(brown);
}
CSS
mybutton.style_context.add_provider(css_provider, Gtk::StyleProvider::PRIORITY_USER)
win.add(mybutton)

win.show_all

Gtk.main