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

public class Replay.Windows.MainWindow : Hdy.Window {

    private Replay.Layouts.MainLayout main_layout;

    private Gee.List<Replay.Emulator> emulators = new Gee.ArrayList<Replay.Emulator> ();

    public MainWindow (Replay.Application application) {
        Object (
            application: application,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        main_layout = new Replay.Layouts.MainLayout (this);
        main_layout.button_clicked.connect (() => {
            var emulator = new Replay.Emulator (this);
            emulator.load_rom ("file:///home/avojak/Downloads/Tetris (World).gb");
            emulator.open ();
            emulator.start ();
            emulators.add (emulator);
        });
        //  var core = new Retro.Core ("/app/share/libretro/cores/gearboy_libretro.so");
        //  core.set_medias ({ "file:///home/avojak/Downloads/Tetris (World).gb" });
        //  try {
        //      core.boot ();
        //  }
        //  catch (Error e) {
        //      critical (e.message);
        //      //  return 1;
        //  }
        //  var view = new Retro.CoreView ();
        //  view.set_as_default_controller (core);
        //  view.set_core (core);
        //  view.show ();
        //  core.set_keyboard (view);

        //  add (view);
        add (main_layout);

        restore_window_position ();

        this.destroy.connect (() => {
            // Do stuff before closing the application
            // TODO: Save state of games
            // TODO: Stop emulator cores

            //  GLib.Process.exit (0);
        });

        this.delete_event.connect (before_destroy);

        show_app ();

        //  core.run ();
    }

    private void restore_window_position () {
        move (Replay.Application.settings.get_int ("pos-x"), Replay.Application.settings.get_int ("pos-y"));
        resize (Replay.Application.settings.get_int ("window-width"), Replay.Application.settings.get_int ("window-height"));
    }

    public void show_app () {
        show_all ();
        //  show ();
        present ();
    }

    public bool before_destroy () {
        update_position_settings ();
        destroy ();
        return true;
    }

    private void update_position_settings () {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        Replay.Application.settings.set_int ("pos-x", x);
        Replay.Application.settings.set_int ("pos-y", y);
        Replay.Application.settings.set_int ("window-width", width);
        Replay.Application.settings.set_int ("window-height", height);
    }

}
