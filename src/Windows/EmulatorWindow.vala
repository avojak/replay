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

    public EmulatorWindow (Replay.Application application) {
        Object (
            application: application,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        layout = new Replay.Layouts.EmulatorLayout (this);
        layout.pause_button_clicked.connect (() => {
            pause_button_clicked ();
        });
        layout.resume_button_clicked.connect (() => {
            resume_button_clicked ();
        });
        add (layout);

        // TODO: Automatically pause/resume when the window loses/gains focus?

        // TODO: Somewhere should show which core is being used

        restore_window_position ();

        this.delete_event.connect (before_destroy);

        show_emulator ();
    }

    private void restore_window_position () {
        move (Replay.Application.settings.get_int ("emu-pos-x"), Replay.Application.settings.get_int ("emu-pos-y"));
        resize (Replay.Application.settings.get_int ("emu-window-width"), Replay.Application.settings.get_int ("emu-window-height"));
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

        Replay.Application.settings.set_int ("emu-pos-x", x);
        Replay.Application.settings.set_int ("emu-pos-y", y);
        Replay.Application.settings.set_int ("emu-window-width", width);
        Replay.Application.settings.set_int ("emu-window-height", height);
    }

    private void show_emulator () {
        show_all ();
        present ();
    }

    public unowned Retro.CoreView get_core_view () {
        return layout.view;
    }

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();

}
