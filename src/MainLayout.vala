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

public class Replay.MainLayout : Gtk.Grid {

    public unowned Replay.MainWindow window { get; construct; }

    private Replay.Widgets.HeaderBar header_bar;
    private Gtk.Grid grid;

    public MainLayout (Replay.MainWindow window) {
        Object (
            window: window
        );
    }

    construct {
        header_bar = new Replay.Widgets.HeaderBar ();
        header_bar.get_style_context ().add_class ("default-decoration");
        header_bar.debug_button_clicked.connect (() => {
            debug_button_clicked ();
        });

        var start_button = new Gtk.Button.with_label ("Start");
        start_button.clicked.connect (() => {
            start_button_clicked ();
        });
        var stop_button = new Gtk.Button.with_label ("Stop");
        stop_button.clicked.connect (() => {
            stop_button_clicked ();
        });

        grid = new Gtk.Grid () {
            expand = true
        };
        grid.attach (start_button, 0, 0);
        grid.attach (stop_button, 1, 0);

        attach (header_bar, 0, 0);
        attach (grid, 0, 1);

        show_all ();
    }

    public signal void start_button_clicked ();
    public signal void stop_button_clicked ();

    public signal void debug_button_clicked ();

}