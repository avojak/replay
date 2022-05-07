/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.WelcomeView : Granite.Widgets.Welcome {

    private static Gtk.CssProvider provider;

    public const string NAME = "Welcome";

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/WelcomeView.css");
    }

    public WelcomeView () {
        Object (
            title: _("Welcome to Replay"),
            subtitle: _("Replay your favorite classic video games!"),
            valign: Gtk.Align.FILL,
            halign: Gtk.Align.FILL,
            expand: true
        );
    }

    construct {
        get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        append ("folder-saved-search", "Choose Game Directory", "Select the directory where your ROM file are located.");

        activated.connect (index => {
            switch (index) {
                default:
                    assert_not_reached ();
            }
        });
    }

}
