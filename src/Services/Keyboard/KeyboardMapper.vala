/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/keyboard/keyboard-mapper.vala
public class Replay.Services.Keyboard.KeyboardMapper : Replay.Services.DeviceMapper<Retro.KeyJoypadMapping>, GLib.Object {

    private unowned Replay.Views.GamepadView gamepad_view;

    private Replay.Services.Gamepad.GamepadInput[] mapping_inputs;
    private Replay.Services.Gamepad.GamepadInput input;
    private uint current_input_index = 0;
    private Replay.Services.Keyboard.KeyboardMappingBuilder mapping_builder;

    public KeyboardMapper (Replay.Services.Gamepad.GamepadViewConfiguration configuration,
        Replay.Views.GamepadView gamepad_view, Replay.Services.Gamepad.GamepadInput[] mapping_inputs) {
        this.gamepad_view = gamepad_view;
        this.mapping_inputs = mapping_inputs;
        gamepad_view.configuration = configuration;
    }

    public void start () {
        mapping_builder = new Replay.Services.Keyboard.KeyboardMappingBuilder ();
        current_input_index = 0;
        connect_to_device ();
        next_input ();
    }

    public void stop () {
        disconnect_from_device ();
    }

    public void skip () {
        next_input ();
    }

    private void connect_to_device () {
        gamepad_view.get_toplevel ().key_release_event.connect (on_keyboard_event);
    }

    private void disconnect_from_device () {
        gamepad_view.get_toplevel ().key_release_event.disconnect (on_keyboard_event);
    }

    private bool on_keyboard_event (Gdk.EventKey key) {
        if (mapping_builder.set_input_mapping (input, key.hardware_keycode)) {
            next_input ();
        }
        return true;
    }

    private void next_input () {
        if (current_input_index == mapping_inputs.length) {
            finished (mapping_builder.mapping);
            return;
        }

        gamepad_view.reset ();
        input = mapping_inputs[current_input_index++];
        gamepad_view.highlight (input, true);

        prompt (_("Press the suitable key on your keyboard…"));
    }

}
