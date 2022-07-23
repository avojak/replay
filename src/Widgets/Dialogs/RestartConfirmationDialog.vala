/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.Dialogs.RestartConfirmationDialog : Granite.MessageDialog {

    public RestartConfirmationDialog (Gtk.Window window) {
        Object (
            deletable: false,
            resizable: false,
            transient_for: window,
            modal: true
        );
    }

    construct {
        image_icon = new ThemedIcon ("dialog-warning");
        primary_text = _("Are you sure you want to restart the game?");
        secondary_text = _("All unsaved progress will be lost.");

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        var remove_button = add_button (_("Yes, Restart the Game"), Gtk.ResponseType.OK);
        unowned Gtk.StyleContext style_context = remove_button.get_style_context ();
        style_context.add_class ("destructive-action");

        custom_bin.show_all ();
    }

}
