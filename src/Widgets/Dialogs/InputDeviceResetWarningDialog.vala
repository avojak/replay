/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.Dialogs.InputDeviceResetWarningDialog : Granite.MessageDialog {

    public InputDeviceResetWarningDialog (Gtk.Window window) {
        Object (
            deletable: false,
            resizable: false,
            transient_for: window,
            modal: true
        );
    }

    construct {
        image_icon = new ThemedIcon ("dialog-warning");
        primary_text = _("Are you sure you want to reset this input device?");
        secondary_text = _("The button mapping will be lost, and you will need to re-configure the device.");

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        var remove_button = add_button (_("Yes, Reset the Device"), Gtk.ResponseType.OK);
        unowned Gtk.StyleContext style_context = remove_button.get_style_context ();
        style_context.add_class ("destructive-action");

        custom_bin.show_all ();
    }

}
