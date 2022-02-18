/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Application : Gtk.Application {

    public static GLib.Settings settings;
    public static Replay.EmulatorManager emulator_manager;

    private GLib.List<Replay.Windows.MainWindow> windows;

    public Application () {
        Object (
            application_id: Constants.APP_ID,
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
    }

    static construct {
        info ("%s version: %s", Constants.APP_ID, Constants.VERSION);
        info ("Kernel version: %s", Posix.utsname ().release);
    }

    construct {
        settings = new GLib.Settings (Constants.APP_ID);
        windows = new GLib.List<Replay.Windows.MainWindow> ();

        emulator_manager = new Replay.EmulatorManager (this);

        startup.connect ((handler) => {
            Hdy.init ();
        });
    }

    public override void window_added (Gtk.Window window) {
        windows.append (window as Replay.Windows.MainWindow);
        base.window_added (window);
    }

    public override void window_removed (Gtk.Window window) {
        windows.remove (window as Replay.Windows.MainWindow);
        base.window_removed (window);
    }

    private Replay.Windows.MainWindow add_new_window () {
        var window = new Replay.Windows.MainWindow (this);
        this.add_window (window);
        return window;
    }

    protected override int command_line (ApplicationCommandLine command_line) {
        string[] command_line_arguments = parse_command_line_arguments (command_line.get_arguments ());
        // If the application wasn't already open, activate it now
        if (windows.length () == 0) {
            //  queued_command_line_arguments = command_line_arguments;
            activate ();
        } else {
            handle_command_line_arguments (command_line_arguments);
        }
        return 0;
    }

    private string[] parse_command_line_arguments (string[] command_line_arguments) {
        if (command_line_arguments.length == 0) {
            return command_line_arguments;
        } else {
            // For Flatpak, the first commandline argument is the app ID, so we need to filter it out
            if (command_line_arguments[0] == Constants.APP_ID) {
                return command_line_arguments[1:command_line_arguments.length - 1];
            } {
                return command_line_arguments;
            }
        }
    }

    private void handle_command_line_arguments (string[] argv) {
        //  GLib.List<Iridium.Models.IRCURI> uris = new GLib.List<Iridium.Models.IRCURI> ();
        //  foreach (var uri_string in argv) {
        //      try {
        //          Soup.URI uri = new Soup.URI (uri_string);
        //          if (uri == null) {
        //              throw new OptionError.BAD_VALUE ("Argument is not a URL.");
        //          }
        //          if (uri.scheme != "irc") {
        //              throw new OptionError.BAD_VALUE ("Cannot open non-irc: URL");
        //          }
        //          debug ("Received command line URI: %s", uri.to_string (false));
        //          uris.append (new Iridium.Models.IRCURI (uri));
        //      } catch (OptionError e) {
        //          warning ("Argument parsing error: %s", e.message);
        //      }
        //  }

        //  var window = get_active_window ();
        //  // Ensure that the window is presented to the user when handling the URL.
        //  // This can happen when the application is already open but in the background.
        //  window.present ();
        //  ((Iridium.MainWindow) window).handle_uris (uris);
    }

    protected override void activate () {
        // Respect the system style preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
        
        this.add_new_window ();
    }

    public static int main (string[] args) {
        var app = new Replay.Application ();
        return app.run (args);
    }

}
