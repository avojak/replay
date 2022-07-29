/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/keyboard/keyboard-tester.vala
public class Replay.Services.Keyboard.KeyboardTester : Replay.Services.DeviceTester, GLib.Object {

    public Retro.KeyJoypadMapping mapping { get; set; }

    private unowned Replay.Views.GamepadView gamepad_view;

    public KeyboardTester (Replay.Services.Gamepad.GamepadViewConfiguration configuration,
            Replay.Views.GamepadView gamepad_view) {
        this.gamepad_view = gamepad_view;
        gamepad_view.configuration = configuration;
    }

    public void start () {
        gamepad_view.reset ();
        connect_to_device ();
    }

    public void stop () {
        disconnect_from_device ();
    }

    private void connect_to_device () {
        debug ("Connected to keyboard");
        var window = gamepad_view.get_toplevel ();
        window.key_press_event.connect (on_key_press_event);
        window.key_release_event.connect (on_key_release_event);
    }

    private void disconnect_from_device () {
        var window = gamepad_view.get_toplevel ();
        window.key_press_event.disconnect (on_key_press_event);
        window.key_release_event.disconnect (on_key_release_event);
    }

    private bool on_key_press_event (Gdk.EventKey key) {
        update_gamepad_view (key, true);
        return true;
    }

    private bool on_key_release_event (Gdk.EventKey key) {
        update_gamepad_view (key, false);
        return true;
    }

    private void update_gamepad_view (Gdk.EventKey key, bool highlight) {
        int count = Retro.ControllerType.JOYPAD.get_id_count ();
        for (Retro.JoypadId joypad_id = 0; joypad_id < count; joypad_id += 1) {
            if (mapping.get_button_key (joypad_id) == key.hardware_keycode) {
                var code = joypad_id.to_button_code ();
                gamepad_view.highlight ({ EventCode.EV_KEY, code }, highlight);
            }
        }
    }

}
