/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
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
