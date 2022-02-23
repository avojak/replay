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

    private Gtk.Paned paned;
    private Replay.Views.LibraryView library_view;
    private Replay.Widgets.LibrarySidePanel library_side_panel;

    public MainLayout (Replay.Windows.MainWindow window) {
        Object (
            window: window
        );
    }

    construct {
        library_view = new Replay.Views.LibraryView ();
        library_view.game_selected.connect (on_game_selected);
        library_view.add_game (new Replay.Models.Game () {
            display_name = "Pokemon - Fire Red Version",
            rom_path = "/home/avojak/Downloads/Pokemon - Fire Red Version (U) (V1.1).gba"
        });

        library_side_panel = new Replay.Widgets.LibrarySidePanel ();

        var header_group = new Hdy.HeaderGroup ();
        header_group.add_header_bar (library_side_panel.header_bar);
        header_group.add_header_bar (library_view.header_bar);

        var button = new Gtk.Button.with_label ("Start") {
            hexpand = true
        };
        button.clicked.connect (() => {
            button_clicked ();
        });

        paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 240
        };
        paned.pack1 (library_side_panel, false, false);
        paned.pack2 (library_view, true, false);

        attach (paned, 0, 0);

        show_all ();
    }

    private void on_game_selected (Replay.Models.Game game) {
        debug ("game selected");
        game_selected (game);
    }

    public signal void button_clicked ();
    public signal void game_selected (Replay.Models.Game game);

}
