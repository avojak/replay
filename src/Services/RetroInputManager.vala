/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/retro/retro-input-manager.vala
public class Replay.Services.RetroInputManager : GLib.Object {

    private unowned Retro.Core core;
    private unowned Retro.CoreView view;
    private Replay.Services.Keyboard.KeyboardMappingManager keyboard_mapping_manager;
    private Manette.Monitor device_monitor;
    private Gee.Map<uint, Manette.Device> devices;
    private Gee.Map<uint, Retro.Controller> controllers;

    public RetroInputManager (Retro.Core core, Retro.CoreView view) {
        this.core = core;
        this.view = view;

        keyboard_mapping_manager = new Replay.Services.Keyboard.KeyboardMappingManager ();
        device_monitor = new Manette.Monitor ();
        devices = new Gee.HashMap<uint, Manette.Device> ();
        controllers = new Gee.HashMap<uint, Retro.Controller> ();

        view.set_key_joypad_mapping (keyboard_mapping_manager.mapping);
        view.set_as_default_controller (core);

        // Unset default joypad controller to avoid duplicating input on all ports
        core.set_default_controller (Retro.ControllerType.JOYPAD, null);
        //  core_view_joypad = view.as_controller (Retro.ControllerType.JOYPAD);

        Manette.Device device = null;
        var iterator = device_monitor.iterate ();
        while (iterator.next (out device)) {
            var gamepad = new Replay.Services.RetroGamepad (device);
            var port = controllers.size;
            devices.set (port, device);
            controllers.set (port, gamepad);
            debug ("Setting device %s on port %d", device.get_name (), port);
            core.set_controller (port, gamepad);
            device.disconnected.connect (on_device_disconnected);
        }

        device_monitor.device_connected.connect (on_device_connected);
        keyboard_mapping_manager.changed.connect (on_keyboard_mapping_changed);
    }

    private void on_device_connected (Manette.Device device) {
        // TODO
    }

    private void on_device_disconnected (Manette.Device device) {
        foreach (var entry in devices.entries) {
            if (entry.value == device) {
                debug ("Device %s disconnected from port %d", device.get_name (), (int) entry.key);
                disconnect_port (entry.key);
            }
        }
    }

    private void disconnect_port (uint port) {
        // TODO
    }

    private void on_keyboard_mapping_changed () {
        view.set_key_joypad_mapping (keyboard_mapping_manager.mapping);
    }

}
