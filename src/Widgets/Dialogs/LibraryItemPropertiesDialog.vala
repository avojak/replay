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

public class Replay.Widgets.Dialogs.LibraryItemPropertiesDialog : Granite.Dialog {

    public LibraryItemPropertiesDialog (Replay.Windows.LibraryWindow library_window) {
        Object (
            deletable: false,
            resizable: false,
            transient_for: library_window,
            modal: false
        );
    }

    construct {
        // Create the header
        var header_grid = new Gtk.Grid ();
        header_grid.margin_start = 30;
        header_grid.margin_end = 30;
        header_grid.margin_bottom = 10;
        header_grid.column_spacing = 10;

        // Add the action buttons
        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (close_button, 0);
    }

}
