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

    private GLib.List<Replay.MainWindow> windows;

    public Application () {
        Object (
            application_id: Constants.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        //  Granite.Services.Logger.initialize (Constants.APP_ID);
        //  if (is_dev_mode ()) {
        //      Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        //  } else {
        //      Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.WARN;
        //  }
        info ("%s version: %s", Constants.APP_ID, Constants.VERSION);
        info ("Kernel version: %s", Posix.utsname ().release);
    }

    construct {
        settings = new GLib.Settings (Constants.APP_ID);
        windows = new GLib.List<Replay.MainWindow> ();

        startup.connect ((handler) => {
            Hdy.init ();
        });
    }

    public static bool is_dev_mode () {
        return Constants.APP_ID.has_suffix ("-dev");
    }

    public override void window_added (Gtk.Window window) {
        windows.append (window as Replay.MainWindow);
        base.window_added (window);
    }

    public override void window_removed (Gtk.Window window) {
        windows.remove (window as Replay.MainWindow);
        base.window_removed (window);
    }

    private Replay.MainWindow add_new_window () {
        var window = new Replay.MainWindow (this);
        this.add_window (window);
        return window;
    }

    protected override void activate () {
        this.add_new_window ();
    }

    public static int main (string[] args) {
        var app = new Replay.Application ();
        return app.run (args);
    }

}