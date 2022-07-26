/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.ControllerSettingsView : Replay.Views.Settings.AbstractSettingsView {

    private Manette.Monitor monitor;
    private Gtk.Stack stack;
    private Gtk.ListBox list_box;

    construct {
        monitor = new Manette.Monitor ();
        monitor.device_connected.connect (on_device_connected);
        monitor.device_disconnected.connect (on_device_disconnected);

        list_box = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.SINGLE,
            activate_on_single_click = true
        };
        list_box.set_header_func (list_box_header_func);
        list_box.row_selected.connect (on_row_selected);

        stack = new Gtk.Stack ();

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 150
        };
        paned.pack1 (list_box, false, false);
        paned.pack2 (stack, true, false);

        var frame = new Gtk.Frame (null) {
            expand = true
        };
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        frame.add (paned);

        attach (frame, 0, 0);

        list_devices ();

        list_box.select_row (list_box.get_row_at_index (0));
    }

    private void list_devices () {
        var keyboard_row = new Replay.Widgets.ControllerSettingsRow.for_keyboard ();
        keyboard_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.NOT_CONFIGURED);
        list_box.add (keyboard_row);
        var keyboard_page = new Replay.Views.Settings.ControllerSettingsPage.for_keyboard (_("Keyboard"));
        stack.add_named (keyboard_page, _("Keyboard"));

        keyboard_page.device_configured.connect (() => {
            keyboard_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.CONFIGURED);
        });
        keyboard_page.configuring.connect (() => {
            keyboard_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.CONFIGURING);
        });
        keyboard_page.configuration_reset.connect (() => {
            keyboard_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.NOT_CONFIGURED);
        });

        Manette.Device device = null;
        var iterator = monitor.iterate ();
        while (iterator.next (out device)) {
            on_device_connected (device);
        }
    }

    private void on_device_connected (Manette.Device device) {
        var device_row = new Replay.Widgets.ControllerSettingsRow.for_device (device);
        device_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.NOT_CONFIGURED);
        list_box.add (device_row);

        var device_page = new Replay.Views.Settings.ControllerSettingsPage.for_gamepad (device.get_name ());
        stack.add_named (device_page, device.get_name ());

        device_page.device_configured.connect (() => {
            device_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.CONFIGURED);
        });
        device_page.configuring.connect (() => {
            device_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.CONFIGURING);
        });
        device_page.configuration_reset.connect (() => {
            device_row.set_status (Replay.Widgets.ControllerSettingsRow.Status.NOT_CONFIGURED);
        });
    }

    private void on_device_disconnected (Manette.Device device) {
        foreach (var row in list_box.get_children ()) {
            if (((Replay.Widgets.ControllerSettingsRow) row).device == device) {
                list_box.remove (row);
                break;
            }
        }
        stack.remove (stack.get_child_by_name (device.get_name ()));
    }

    private void list_box_header_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow? row2) {
        var device_row1 = (Replay.Widgets.ControllerSettingsRow) row1;
        var device_row2 = (Replay.Widgets.ControllerSettingsRow) row2;
        if ((device_row2 == null) && (device_row1.device == null)) {
            var label = new Gtk.Label (_("Keyboards")) {
                xalign = 0,
                margin = 3
            };
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            device_row1.set_header (label);
        } else if ((device_row2 == null) || (device_row1.device != device_row2.device)) {
            var label = new Gtk.Label (_("Gamepads")) {
                xalign = 0,
                margin = 3
            };
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            device_row1.set_header (label);
        } else {
            device_row1.set_header (null);
        }
    }

    private void on_row_selected (Gtk.ListBoxRow? row) {
        if (row == null) {
            debug ("Row selected: null");
            list_box.select_row (list_box.get_row_at_index (0));
        } else {
            debug ("Row selected: %s", ((Replay.Widgets.ControllerSettingsRow) row).title);
            var device_row = (Replay.Widgets.ControllerSettingsRow) row;
            stack.set_visible_child_name (device_row.title);
        }
    }

}
