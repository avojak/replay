/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/keyboard/keyboard-mapping-builder.vala
public class Replay.Services.Keyboard.KeyboardMappingBuilder : GLib.Object {

    public Retro.KeyJoypadMapping mapping { get; private set; }

    construct {
        mapping = new Retro.KeyJoypadMapping ();
    }

    public bool set_input_mapping (Replay.Services.Gamepad.GamepadInput input, uint16 keycode) {
        var joypad_id = Retro.JoypadId.from_button_code (input.code);
        int count = Retro.ControllerType.JOYPAD.get_id_count ();

        if (joypad_id >= count) {
            return false;
        }

        for (Retro.JoypadId i = 0; i < count; i += 1) {
            if (mapping.get_button_key (i) == keycode) {
                return false;
            }
        }

        mapping.set_button_key (joypad_id, keycode);

        return true;
    }

}
