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
    //  public static Replay.Services.LibretroCoreRepository core_repository;
    //  public static Replay.Services.GameLibrary game_library;
    //  public static Replay.Services.EmulatorManager emulator_manager;

    public static bool silent = false;

    //  private GLib.List<Replay.Windows.LibraryWindow> library_windows;

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
        settings = new Replay.Services.Settings (); // TODO: Wrap this with a class that handles reading/writing values so that we don't need to know the string keys everywhere
        //  core_repository = Replay.Services.LibretroCoreRepository.get_default ();
        //  game_library = Replay.Services.GameLibrary.get_default ();
        //  emulator_manager = new Replay.Services.EmulatorManager (this);

        //  library_windows = new GLib.List<Replay.Windows.LibraryWindow> ();

        startup.connect ((handler) => {
            Hdy.init ();
        });
    }

    //  public override void window_added (Gtk.Window window) {
    //      this.library_window = window as Replay.Windows.LibraryWindow;
    //      base.window_added (window);
    //  }

    //  public override void window_removed (Gtk.Window window) {
    //      //  library_windows.remove (window as Replay.Windows.LibraryWindow);
    //      this.library_window = null;
    //      base.window_removed (window);
    //  }

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
        //  ((Iridium.LibraryWindow) window).handle_uris (uris);
    }

    // When launching a game without going through the library window, we should still load the library
    // and then lookup the game object by the URI of the ROM or the checksum. That will allow us to load
    // the full model and game data.

    protected override void activate () {
        // This must happen here because the main event loops will have started
        //  core_repository.sql_client = Replay.Services.SQLClient.get_default ();
        //  core_repository.initialize ();
        //  game_library.sql_client = Replay.Services.SQLClient.get_default ();
        //  game_library.initialize ();

        // Respect the system style preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        var client = Replay.Core.Client.get_default ();
        //  if (!silent) {
        this.add_new_window ();
        //  client.core_sources_scanned.connect (() => {
        //      window.update_library ();
        //  });
        //  client.library_sources_scanned.connect (() => {
        //      window.update_systems ();
        //  });
        //  client.scan_all_sources.begin ();
        library_window.show_processing (true);
        client.scan_core_sources_async.begin ((obj, res) => {
            client.scan_core_sources_async.end (res);
            //  library_window.reload_systems ();
            // Scan for games *after* all the cores have been loaded to facilitate mapping games to cores
            // that can play them
            client.scan_library_sources_async.begin ((obj, res) => {
                client.scan_library_sources_async.end (res);
                library_window.reload_library ();
                library_window.show_processing (false);
            });
        });
        //  } else {
        //      client.scan_core_sources.begin ();
        //      client.scan_library_sources.begin ();
        //  }
    }

    public static int main (string[] args) {
        var app = Replay.Application.get_instance ();
        return app.run (args);
    }

}
