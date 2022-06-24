/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Application : Gtk.Application {

    private static GLib.Once<Replay.Application> instance;
    public static unowned Replay.Application get_instance () {
        return instance.once (() => { return new Replay.Application (); });
    }

    public static Replay.Services.Settings settings;

    public static bool silent = false;

    public Replay.Windows.LibraryWindow? library_window;

    public Application () {
        Object (
            application_id: Constants.APP_ID,
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
    }

    static construct {
        info ("%s version: %s", Constants.APP_ID, Constants.VERSION);
        info ("Kernel version: %s", Posix.utsname ().release);
        info ("Bundled core dir: %s", Constants.BUNDLED_LIBRETRO_CORE_DIR);
        info ("Bundled ROM dir: %s", Constants.BUNDLED_ROM_DIR);
        info ("System core dir: %s", Constants.SYSTEM_LIBRETRO_CORE_DIR);
    }

    construct {
        settings = new Replay.Services.Settings ();

        startup.connect ((handler) => {
            Hdy.init ();
        });
    }

    private void add_new_window () {
        this.library_window = new Replay.Windows.LibraryWindow (this);
        library_window.destroy.connect (() => {
            library_window = null;
        });
        this.add_window (library_window);
    }

    protected override int command_line (ApplicationCommandLine command_line) {
        string[] command_line_arguments = parse_command_line_arguments (command_line.get_arguments ());
        // If the application wasn't already open, activate it now
        if (library_window == null) {
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
            }
            return command_line_arguments;
        }
    }

    private void handle_command_line_arguments (string[] argv) {
        // TODO
    }

    // When launching a game without going through the library window, we should still load the library
    // and then lookup the game object by the URI of the ROM or the checksum. That will allow us to load
    // the full model and game data.

    protected override void activate () {
        // Respect the system style preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        var client = Replay.Core.Client.get_default ();

        this.add_new_window ();

        library_window.show_processing (true);
        client.scan_core_sources_async.begin ((obj, res) => {
            client.scan_core_sources_async.end (res);
            // Scan for games *after* all the cores have been loaded to facilitate mapping games to cores
            // that can play them
            client.scan_library_sources_async.begin ((obj, res) => {
                client.scan_library_sources_async.end (res);
                library_window.reload_library ();
                library_window.show_processing (false);
            });
        });
    }

    public static int main (string[] args) {
        var app = Replay.Application.get_instance ();
        return app.run (args);
    }

}
