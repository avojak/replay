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

public class Replay.MainWindow : Hdy.Window {

    public unowned Replay.Application app { get; construct; }

    private Replay.MainLayout main_layout;

    private Replay.DMG.Emulator? dmg;

    public MainWindow (Replay.Application application) {
        Object (
            application: application,
            app: application,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        main_layout = new Replay.MainLayout (this);
        add (main_layout);

        move (Replay.Application.settings.get_int ("pos-x"), Replay.Application.settings.get_int ("pos-y"));
        resize (Replay.Application.settings.get_int ("window-width"), Replay.Application.settings.get_int ("window-height"));

        this.destroy.connect (() => {
            // Do stuff before closing the application

            // Stop running emulator
            if (dmg != null) {
                dmg.stop ();
            }

            GLib.Process.exit (0);
        });

        this.delete_event.connect (before_destroy);

        main_layout.start_button_clicked.connect (on_start_button_clicked);
        main_layout.stop_button_clicked.connect (on_stop_button_clicked);

        show_app ();
    }

    public void show_app () {
        show_all ();
        show ();
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

    public void on_start_button_clicked () {
        // TODO: Add named view for the emulator
        if (dmg != null) {
            return;
        }
        dmg = new Replay.DMG.Emulator ();
        dmg.start ();
    }

    public void on_stop_button_clicked () {
        if (dmg == null) {
            return;
        }
        dmg.stop ();
        dmg = null;
    }

}
