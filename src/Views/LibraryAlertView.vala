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
