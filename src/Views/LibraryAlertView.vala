/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.LibraryAlertView : Granite.Widgets.AlertView {

    private static Gtk.CssProvider provider;

    public const string NAME = "Alert";

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/AlertView.css");
    }

    public LibraryAlertView () {
        Object (
            title: _(""),
            description: _(""),
            icon_name: ""
        );
    }

    construct {
        get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

}
