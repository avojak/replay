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

    public MainHeaderBar () {
        Object (
            title: Constants.APP_NAME,
            show_close_button: true,
            has_subtitle: false
        );
    }

    construct {
        var settings_button = new Gtk.MenuButton ();
        settings_button.image = new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        settings_button.tooltip_text = _("Menu");
        settings_button.relief = Gtk.ReliefStyle.NONE;
        settings_button.valign = Gtk.Align.CENTER;

        var settings_popover_grid = new Gtk.Grid ();
        settings_popover_grid.margin_bottom = 3;
        settings_popover_grid.orientation = Gtk.Orientation.VERTICAL;
        settings_popover_grid.width_request = 200;
        //  settings_popover_grid.attach (toggle_sidebar_menu_item, 0, 0, 1, 1);
        //  settings_popover_grid.attach (reset_marker_menu_item, 0, 1, 1, 1);
        //  settings_popover_grid.attach (preferences_menu_item, 0, 2, 1, 1);
        //  settings_popover_grid.attach (create_menu_separator (), 0, 3, 1, 1);
        //  settings_popover_grid.attach (quit_menu_item, 0, 4, 1, 1);
        settings_popover_grid.show_all ();

        var settings_popover = new Gtk.Popover (null);
        settings_popover.add (settings_popover_grid);

        settings_button.popover = settings_popover;

        pack_end (settings_button);
    }

}
