/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/gamepad/gamepad-tester.vala
public class Replay.Services.Gamepad.GamepadTester : Replay.Services.DeviceTester, GLib.Object {

    private unowned Manette.Device device;
    private Replay.Services.Gamepad.GamepadViewConfiguration configuration;
    private unowned Replay.Views.GamepadView gamepad_view;

    public GamepadTester (Manette.Device device, Replay.Services.Gamepad.GamepadViewConfiguration configuration,
           Replay.Views.GamepadView gamepad_view) {
        this.device = device;
        this.gamepad_view = gamepad_view;
        this.configuration = configuration;
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
        device.button_press_event.connect (on_button_press_event);
        device.button_release_event.connect (on_button_release_event);
        device.absolute_axis_event.connect (on_absolute_axis_event);
    }

    private void disconnect_from_device () {
        device.button_press_event.disconnect (on_button_press_event);
        device.button_release_event.disconnect (on_button_release_event);
        device.absolute_axis_event.disconnect (on_absolute_axis_event);
    }

    private void on_button_press_event (Manette.Event event) {
        uint16 button;
        if (event.get_button (out button)) {
            gamepad_view.highlight ({ EventCode.EV_KEY, button }, true);
        }
    }

    private void on_button_release_event (Manette.Event event) {
        uint16 button;
        if (event.get_button (out button)) {
            gamepad_view.highlight ({ EventCode.EV_KEY, button }, false);
        }
    }

    private void on_absolute_axis_event (Manette.Event event) {
        uint16 axis;
        double value;
        if (event.get_absolute (out axis, out value)) {
            gamepad_view.set_analog ({ EventCode.EV_ABS, axis }, value);
        }
    }

}
