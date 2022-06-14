/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.LibraryLoadingView : Granite.Widgets.AlertView {

    private static Gtk.CssProvider provider;

    public const string NAME = "Loading";

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/AlertView.css");
    }

    public LibraryLoadingView () {
        Object (
            title: _("Loading Game Library"),
            description: _("Loading all systems and games in the library"),
            icon_name: "emblem-synchronized"
        );
    }

    construct {
        get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

}
