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

public class Replay.Layouts.MainLayout : Gtk.Grid {

    public unowned Replay.Windows.MainWindow window { get; construct; }

    private Replay.Widgets.MainHeaderBar header_bar;
    private Gtk.ScrolledWindow scrolled_window;
    private Replay.Views.LibraryView library_view;

    public MainLayout (Replay.Windows.MainWindow window) {
        Object (
            window: window
        );
    }

    construct {
        header_bar = new Replay.Widgets.MainHeaderBar ();
        header_bar.get_style_context ().add_class ("default-decoration");

        library_view = new Replay.Views.LibraryView ();
        library_view.add_game (new Replay.Models.Game () {
            display_name = "Pokemon - Fire Red Version"
        });

        scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (library_view);

        var button = new Gtk.Button.with_label ("Start") {
            hexpand = true
        };
        button.clicked.connect (() => {
            button_clicked ();
        });

        attach (header_bar, 0, 0);
        attach (scrolled_window, 0, 1);
        attach (button, 0, 2);

        show_all ();
    }

    public signal void button_clicked ();

}
