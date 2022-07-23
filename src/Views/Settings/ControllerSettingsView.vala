/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.ControllerSettingsView : Replay.Views.Settings.AbstractSettingsView {

    private Manette.Monitor monitor;

    construct {
        monitor = new Manette.Monitor ();
        monitor.device_connected.connect (list_devices);
        monitor.device_disconnected.connect (list_devices);
        list_devices ();

        var frame = new Gtk.Frame (null) {
            expand = true
        };
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 30
        };
        frame.add (paned);

        var settings_stack = new Gtk.Stack ();
        settings_stack.add_named (new Replay.Views.Settings.ControllerSettingsPage.for_keyboard (true), _("Keyboard"));

        //  foreach (var entry in Replay.Core.Client.get_default ().core_repository.get_cores_by_manufacturer ().entries) {
        //      int index = 0;
        //      foreach (var core in entry.value) {
        //          settings_stack.add_named (new Replay.Views.Settings.SystemSettingsPage.for_core (core, (index == 0)), core.info.core_name);
        //          index++;
        //      }
        //  }

        var settings_sidebar = new Granite.SettingsSidebar (settings_stack) {
            expand = true
        };

        paned.pack1 (settings_sidebar, false, false);
        paned.pack2 (settings_stack, true, false);

        attach (frame, 0, 0);
    }

    private void list_devices () {
        Manette.Device device = null;
        debug ("========");
        var iterator = monitor.iterate ();
        while (iterator.next (out device)) {
            debug (device.get_name ());
        }
        debug ("========");
    }

}
