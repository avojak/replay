/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.Dialogs.AboutDialog : Granite.Dialog {

    public AboutDialog (Replay.Windows.LibraryWindow library_window) {
        Object (
            deletable: false,
            resizable: false,
            transient_for: library_window,
            modal: false
        );
    }

    construct {
        // Create the header
        var grid = new Gtk.Grid ();
        grid.margin_start = 30;
        grid.margin_end = 30;
        grid.margin_bottom = 10;
        grid.column_spacing = 10;

        grid.attach (new Gtk.Image () {
            gicon = new GLib.ThemedIcon (Constants.APP_ID),
            pixel_size = 128,
            halign = Gtk.Align.CENTER
        }, 0, 0);
        grid.attach (new Granite.HeaderLabel (Constants.APP_NAME) {
            halign = Gtk.Align.CENTER
        }, 0, 1);
        grid.attach (new Gtk.Label (Constants.VERSION), 0, 2);
        grid.attach (new Gtk.LinkButton.with_label ("https://github.com/avojak/replay", _("Website")) {
            halign = Gtk.Align.CENTER,
            margin_top = 8
        }, 0, 3);
        grid.attach (new Gtk.Label (_("All video game box artwork, title screens, in-game screenshots, and metadata are provided by Libretro.")) {
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD,
            max_width_chars = 50,
            justify = Gtk.Justification.CENTER,
            //  use_markup = true,
            margin_top = 8
        }, 0, 5);

        get_content_area ().add (grid);

        // Add the action buttons
        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (close_button, 0);
    }

}
