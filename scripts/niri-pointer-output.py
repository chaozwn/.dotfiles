#!/usr/bin/python3
"""Print the Wayland output connector currently under the pointer."""

import gi

gi.require_version("Gdk", "4.0")
gi.require_version("Gtk", "4.0")
from gi.repository import Gdk, GLib, Gtk


class App(Gtk.Application):
    def __init__(self):
        super().__init__()
        self.output = None

    def do_activate(self):
        css = Gtk.CssProvider()
        css.load_from_string("window { background: alpha(black, 0.004); }")
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )
        monitors = Gdk.Display.get_default().get_monitors()
        for i in range(monitors.get_n_items()):
            monitor = monitors.get_item(i)
            window = Gtk.Window(application=self, decorated=False)
            window.fullscreen_on_monitor(monitor)
            motion = Gtk.EventControllerMotion()
            motion.connect("enter", self.on_enter, monitor)
            window.add_controller(motion)
            window.present()
        GLib.timeout_add(800, self.quit)

    def on_enter(self, _controller, _x, _y, monitor):
        self.output = monitor.get_connector()
        self.quit()


def main():
    app = App()
    app.run(None)
    if app.output:
        print(app.output)


if __name__ == "__main__":
    main()
