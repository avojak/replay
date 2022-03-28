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

public class Replay.Widgets.GameGridDetailsPanel : Gtk.Grid {

    private Gtk.Label title_label;

    public GameGridDetailsPanel () {
        Object (
            expand: true
        );
    }

    construct {
        title_label = new Gtk.Label ("") {
            halign = Gtk.Align.START,
            hexpand = true
        };
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        title_label.set_line_wrap (false);

        attach (title_label, 0, 0);
    }

    public void update_title (string title) {
        title_label.set_text (title);
    }

}
