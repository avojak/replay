/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
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

public class Replay.Views.Settings.SettingsView : Gtk.Grid {

    private static Gtk.CssProvider provider;

    private Hdy.HeaderBar left_header_bar;
    private Hdy.HeaderBar right_header_bar;
    private Gtk.Stack settings_stack;

    public SettingsView () {
        Object (
            expand: true
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/SettingsHeaderbar.css");
    }

    construct {
        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 150
        };

        var settings_views = create_settings_views ();
        var side_panel = create_side_panel (settings_stack);

        paned.pack1 (side_panel, false, false);
        paned.pack2 (settings_views, true, false);

        attach (paned, 0, 0);

        var header_group = new Hdy.HeaderGroup ();
        header_group.add_header_bar (left_header_bar);
        header_group.add_header_bar (right_header_bar);

        show_all ();

        load_settings ();
    }

    private Gtk.Grid create_side_panel (Gtk.Stack settings_pages) {
        left_header_bar = new Hdy.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };
        left_header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        left_header_bar.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Set the dark/light style class based on current preference, but also listen for changes if a change
        // occurs while the window is open!
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        left_header_bar.get_style_context ().add_class (gtk_settings.gtk_application_prefer_dark_theme ? "dark" : "light");
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            if (gtk_settings.gtk_application_prefer_dark_theme) {
                left_header_bar.get_style_context ().remove_class ("light");
                left_header_bar.get_style_context ().add_class ("dark");
            } else {
                left_header_bar.get_style_context ().remove_class ("dark");
                left_header_bar.get_style_context ().add_class ("light");
            }
        });

        var settings_sidebar = new Granite.SettingsSidebar (settings_pages) {
            expand = true
        };

        var side_panel = new Gtk.Grid ();
        side_panel.attach (left_header_bar, 0, 0);
        side_panel.attach (settings_sidebar, 0, 1);

        return side_panel;
    }

    private Gtk.Grid create_settings_views () {
        right_header_bar = new Hdy.HeaderBar () {
            title = _("Preferences"),
            show_close_button = true,
            has_subtitle = false
        };
        right_header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        settings_stack = new Gtk.Stack ();
        settings_stack.add_named (new Replay.Views.Settings.CoresSettingsView (), "cores_settings_page");
        settings_stack.add_named (new Replay.Views.Settings.GamesSettingsView (), "games_settings_page");
        settings_stack.add_named (new Replay.Views.Settings.DisplaySettingsView (), "display_settings_page");

        var grid = new Gtk.Grid ();
        grid.attach (right_header_bar, 0, 0);
        grid.attach (settings_stack, 0, 1);

        return grid;
    }

    private void load_settings () {
        // TODO
    }

}
