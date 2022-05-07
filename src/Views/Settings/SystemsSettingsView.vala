/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
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
