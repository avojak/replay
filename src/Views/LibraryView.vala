/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
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

public class Replay.Views.LibraryView : Gtk.Grid {

    public Hdy.HeaderBar header_bar { get; construct; }

    private Gtk.FlowBox flow_box;

    public LibraryView () {
        Object (
            expand: true
        );
    }

    construct {
        header_bar = new Replay.Widgets.MainHeaderBar ();

        flow_box = new Gtk.FlowBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE,
            homogeneous = true,
            expand = true,
            margin = 12,
            valign = Gtk.Align.START
        };

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (flow_box);

        attach (header_bar, 0, 0);
        attach (scrolled_window, 0, 1);

        show_all ();
    }

    public void add_game (Replay.Models.Game game) {
        var item = new Replay.Widgets.LibraryItem.for_game (game);
        item.activate.connect (() => {
            debug ("Item activated");
            game_selected (game);
        });
        flow_box.add (item);
    }

    public signal void game_selected (Replay.Models.Game game);

}