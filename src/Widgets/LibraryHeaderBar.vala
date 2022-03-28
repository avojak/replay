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

public class Replay.Widgets.MainHeaderBar : Hdy.HeaderBar {

    private Gtk.Button return_button;
    private Gtk.Separator return_button_separator;

    public MainHeaderBar () {
        Object (
            title: Constants.APP_NAME,
            show_close_button: true,
            has_subtitle: false
            //  decoration_layout: ":maximize"
        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        return_button = new Gtk.Button.with_label (_("Library")) {
            no_show_all = true,
            valign = Gtk.Align.CENTER,
            vexpand = false
        };
        return_button.get_style_context ().add_class ("back-button");
        return_button.clicked.connect (() => {
            view_return ();
        });
        return_button_separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        return_button_separator.no_show_all = true;

        // TODO: Add search entry

        // TODO: Add ability to open a ROM file not in the library

        // TODO: Allow changing the icon size for the icons in the view

        var settings_button = new Gtk.MenuButton ();
        settings_button.image = new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        settings_button.tooltip_text = _("Menu");
        settings_button.relief = Gtk.ReliefStyle.NONE;
        settings_button.valign = Gtk.Align.CENTER;

        var toggle_sidebar_accellabel = new Granite.AccelLabel.from_action_name (
            _("Toggle Sidebar"),
            Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_TOGGLE_SIDEBAR
        );

        var toggle_sidebar_menu_item = new Gtk.ModelButton ();
        toggle_sidebar_menu_item.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_TOGGLE_SIDEBAR;
        toggle_sidebar_menu_item.get_child ().destroy ();
        toggle_sidebar_menu_item.add (toggle_sidebar_accellabel);

        var preferences_accellabel = new Granite.AccelLabel.from_action_name (
            _("Preferences…"),
            Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_PREFERENCES
        );

        var preferences_menu_item = new Gtk.ModelButton ();
        preferences_menu_item.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_PREFERENCES;
        preferences_menu_item.get_child ().destroy ();
        preferences_menu_item.add (preferences_accellabel);

        var quit_accellabel = new Granite.AccelLabel.from_action_name (
            _("Quit"),
            Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_QUIT
        );

        var quit_menu_item = new Gtk.ModelButton ();
        quit_menu_item.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_QUIT;
        quit_menu_item.get_child ().destroy ();
        quit_menu_item.add (quit_accellabel);

        var settings_popover_grid = new Gtk.Grid ();
        settings_popover_grid.margin_top = 3;
        settings_popover_grid.margin_bottom = 3;
        settings_popover_grid.orientation = Gtk.Orientation.VERTICAL;
        settings_popover_grid.width_request = 200;
        settings_popover_grid.attach (toggle_sidebar_menu_item, 0, 0);
        settings_popover_grid.attach (preferences_menu_item, 0, 1);
        settings_popover_grid.attach (create_menu_separator (), 0, 2);
        settings_popover_grid.attach (quit_menu_item, 0, 3);
        settings_popover_grid.show_all ();

        var settings_popover = new Gtk.Popover (null);
        settings_popover.add (settings_popover_grid);

        settings_button.popover = settings_popover;

        pack_start (return_button);
        pack_start (return_button_separator);

        pack_end (settings_button);
    }

    private Gtk.Separator create_menu_separator (int margin_top = 0) {
        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        menu_separator.margin_top = margin_top;
        return menu_separator;
    }

    public void set_return_button_visible (bool visible) {
        return_button.no_show_all = !visible;
        return_button.visible = visible;
        return_button_separator.no_show_all = !visible;
        return_button_separator.visible = visible;
    }

    public signal void view_return ();

}
