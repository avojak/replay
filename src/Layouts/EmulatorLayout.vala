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

public class Replay.Layouts.EmulatorLayout : Gtk.Grid {

    public unowned Replay.Windows.EmulatorWindow window { get; construct; }
    public Retro.CoreView view { get; construct; }

    private Replay.Widgets.EmulatorHeaderBar header_bar;

    public EmulatorLayout (Replay.Windows.EmulatorWindow window) {
        Object (
            window: window
        );
    }

    construct {
        header_bar = new Replay.Widgets.EmulatorHeaderBar ();
        header_bar.pause_button_clicked.connect (() => {
            pause_button_clicked ();
        });
        header_bar.resume_button_clicked.connect (() => {
            resume_button_clicked ();
        });

        view = new Retro.CoreView () {
            expand = true
        };
        view.set_filter (Replay.Models.VideoFilterMapping.from_short_name (Replay.Application.settings.get_string ("emu-default-filter")));
        // Prevent loss of focus when using arrow keys within a game
        view.key_press_event.connect (() => {
            return true;
        });
        view.show ();

        attach (header_bar, 0, 0);
        attach (view, 0, 1);

        show_all ();

        view.grab_focus ();
    }

    public void show_pause_button () {
        header_bar.set_resume_button_visible (false);
        header_bar.set_pause_button_visible (true);
    }

    public void show_resume_button () {
        header_bar.set_pause_button_visible (false);
        header_bar.set_resume_button_visible (true);
    }

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();

}
