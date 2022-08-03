/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.Dialogs.RestartResumeDialog : Granite.MessageDialog {

    public RestartResumeDialog (Gtk.Window window) {
        Object (
            deletable: false,
            resizable: false,
            transient_for: window,
            modal: true,
            image_icon: new ThemedIcon ("dialog-question"),
            //  badge_icon: new ThemedIcon ("dialog-question"),
            primary_text: _("Would you like to continue your last game?"),
            secondary_text: _("Do you want to resume playing where you left off?")
        );
    }

    construct {
        add_button (_("Restart"), Gtk.ResponseType.CANCEL);
        add_button (_("Resume"), Gtk.ResponseType.OK);

        custom_bin.show_all ();
    }

}
