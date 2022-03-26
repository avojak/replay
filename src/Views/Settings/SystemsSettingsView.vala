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

public class Replay.Views.Settings.SystemsSettingsView : Replay.Views.Settings.AbstractSettingsView {

    construct {
        var frame = new Gtk.Frame (null) {
            expand = true
        };
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 30
        };
        frame.add (paned);

        var settings_stack = new Gtk.Stack ();
        foreach (var entry in Replay.Core.Client.get_default ().core_repository.get_cores_by_manufacturer ().entries) {
            int index = 0;
            foreach (var core in entry.value) {
                settings_stack.add_named (new Replay.Views.Settings.SystemSettingsPage.for_core (core, (index == 0)), core.info.core_name);
                index++;
            }
        }

        var settings_sidebar = new Granite.SettingsSidebar (settings_stack) {
            expand = true
        };

        paned.pack1 (settings_sidebar, false, false);
        paned.pack2 (settings_stack, true, false);

        attach (frame, 0, 0);
    }

}
