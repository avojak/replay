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
            //  core: core
            //  width_request: 500,
            //  height_request: 500
        );
    }

    construct {
        header_bar = new Replay.Widgets.EmulatorHeaderBar ();
        header_bar.get_style_context ().add_class ("default-decoration");
        header_bar.pause_button_clicked.connect (() => {
            pause_button_clicked ();
        });
        header_bar.resume_button_clicked.connect (() => {
            resume_button_clicked ();
        });

        view = new Retro.CoreView () {
            expand = true
        };
        //  view.set_as_default_controller (core);
        //  view.set_core (core);
        view.set_filter (Retro.VideoFilter.SMOOTH);
        view.show ();
        //  core.set_keyboard (view);

        attach (header_bar, 0, 0);
        attach (view, 0, 1);

        show_all ();

        view.grab_focus ();
    }

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();

}
