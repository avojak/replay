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

public class Replay.Windows.EmulatorWindow : Hdy.Window {

    private Replay.Layouts.EmulatorLayout layout;

    public EmulatorWindow (Replay.Windows.MainWindow main_window) {
        Object (
            //  transient_for: main_window,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        if (GLib.File.new_for_path ("/app/share/libretro/cores/gearboy_libretro.so").query_exists ()) {
            debug ("True");
        } else {
            debug ("False");
        }

        //  var descriptor = new Retro.CoreDescriptor ("/app/share/libretro/cores/gearboy_libretro.info");
        //  debug (descriptor.get_name ());

        //  var core = new Retro.Core ("/var/run/host/usr/lib/x86_64-linux-gnu/libretro/mgba_libretro.so");
        var core = new Retro.Core ("/app/share/libretro/cores/gearboy_libretro.so");
        core.set_medias ({ "file:///home/avojak/Downloads/Tetris (World).gb" });
        try {
            core.boot ();
        }
        catch (Error e) {
            critical (e.message);
            //  return 1;
        }

        var view = new Retro.CoreView ();
        view.set_as_default_controller (core);
        view.set_core (core);
        view.show ();
        core.set_keyboard (view);

        //  var grid = new Gtk.Grid () {
        //      expand = true
        //  };
        //  grid.attach (new Replay.Widgets.EmulatorHeaderBar (), 0, 0);
        //  grid.attach (view, 0, 1);
        //  add (grid);

        //  view.show_all ();

        //  add (view);

        layout = new Replay.Layouts.EmulatorLayout (this, core);
        add (layout);

        show_all ();
        present ();

        core.run ();
    }

}