/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Replay.Views.WelcomeView : Granite.Widgets.Welcome {

    private static Gtk.CssProvider provider;

    public const string NAME = _("Welcome");

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

        append ("text-x-vala", "Visit Valadoc", "The canonical source for Vala API references.");
        append ("text-x-source", "Get Granite Source", "Granite's source code is hosted on GitHub.");

        activated.connect (index => {
            switch (index) {
                default:
                    assert_not_reached ();
            }
        });
    }

}
