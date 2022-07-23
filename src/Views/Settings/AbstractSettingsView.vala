/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Replay.Views.Settings.AbstractSettingsView : Gtk.Grid {

    protected AbstractSettingsView () {
        Object (
            halign: Gtk.Align.FILL,
            expand: true,
            margin: 24,
            row_spacing: 6,
            column_spacing: 12
        );
    }

}
