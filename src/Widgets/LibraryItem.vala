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

public class Replay.Widgets.LibraryItem : Gtk.FlowBoxChild {

    public string title { get; construct; }

    public LibraryItem.for_game (Replay.Models.Game game) {
        Object (
            title: game.display_name
        );
    }

    construct {
        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            hexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin = 8
        };
        grid.add (new Gtk.Image () {
            gicon = new ThemedIcon ("application-default-icon"),
            pixel_size = 128,
            margin_bottom = 8
        });
        var label = new Gtk.Label (null) {
            wrap = true,
            max_width_chars = 20,
            justify = Gtk.Justification.CENTER,
            margin_bottom = 8,
            use_markup = true
        };
        label.set_markup (@"<b>$title</b>");
        grid.add (label);

        //  var style_context = get_style_context ();
        //  style_context.add_class (Granite.STYLE_CLASS_CARD);
        //  style_context.add_class (Granite.STYLE_CLASS_ROUNDED);

        child = grid;

        show_all ();
    }

}