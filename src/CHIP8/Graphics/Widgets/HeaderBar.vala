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

public class Replay.CHIP8.Graphics.Widgets.HeaderBar : Hdy.HeaderBar {

    public HeaderBar () {
        Object (
            title: Replay.CHIP8.Interpreter.COMMON_NAME,
            show_close_button: true,
            has_subtitle: false,
            decoration_layout: "close:" // Disable the maximize/restore button
        );
    }

    construct {
        get_style_context ().add_class ("default-decoration");
        
        var debug_button = new Gtk.Button ();
        debug_button.image = new Gtk.Image.from_icon_name ("applications-development-symbolic", Gtk.IconSize.BUTTON);
        debug_button.tooltip_text = "Debug";
        debug_button.relief = Gtk.ReliefStyle.NONE;
        debug_button.valign = Gtk.Align.CENTER;

        debug_button.clicked.connect (() => {
            debug_button_clicked ();
        });

        pack_end (debug_button);
    }

    public signal void debug_button_clicked ();

}
