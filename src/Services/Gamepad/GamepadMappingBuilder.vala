/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/gamepad/gamepad-mapping-builder.vala
public class Replay.Services.Gamepad.GamepadMappingBuilder : GLib.Object {

    private struct GamepadInputSource {
        Replay.Services.Gamepad.GamepadInput input;
        string source;
    }


    // SDL strings are based on Xbox button order:
    //
    //   (Y)
    // (X) (B)
    //   (A)
    //
    // At the same time, /usr/include/linux/input-event-codes.h uses
    // Xbox order for A and B, and Nintendo/libretro order for X and Y:
    //
    //   (X)
    // (Y) (B)
    //   (A)
    //
    // As a result, we swap X and Y buttons to match Xbox order
    private const GamepadInputSource[] INPUT_SOURCES = {
        { { EventCode.EV_ABS, EventCode.ABS_X }, "leftx" },
        { { EventCode.EV_ABS, EventCode.ABS_Y }, "lefty" },
        { { EventCode.EV_ABS, EventCode.ABS_RX }, "rightx" },
        { { EventCode.EV_ABS, EventCode.ABS_RY }, "righty" },
        { { EventCode.EV_KEY, EventCode.BTN_A }, "a" },
        { { EventCode.EV_KEY, EventCode.BTN_B }, "b" },
        { { EventCode.EV_KEY, EventCode.BTN_DPAD_DOWN }, "dpdown" },
        { { EventCode.EV_KEY, EventCode.BTN_DPAD_LEFT }, "dpleft" },
        { { EventCode.EV_KEY, EventCode.BTN_DPAD_RIGHT }, "dpright" },
        { { EventCode.EV_KEY, EventCode.BTN_DPAD_UP }, "dpup" },
        { { EventCode.EV_KEY, EventCode.BTN_MODE }, "guide" },
        { { EventCode.EV_KEY, EventCode.BTN_SELECT }, "back" },
        { { EventCode.EV_KEY, EventCode.BTN_TL }, "leftshoulder" },
        { { EventCode.EV_KEY, EventCode.BTN_TR }, "rightshoulder" },
        { { EventCode.EV_KEY, EventCode.BTN_START }, "start" },
        { { EventCode.EV_KEY, EventCode.BTN_THUMBL }, "leftstick" },
        { { EventCode.EV_KEY, EventCode.BTN_THUMBR }, "rightstick" },
        { { EventCode.EV_KEY, EventCode.BTN_TL2 }, "lefttrigger" },
        { { EventCode.EV_KEY, EventCode.BTN_TR2 }, "righttrigger" },
        { { EventCode.EV_KEY, EventCode.BTN_Y }, "x" },
        { { EventCode.EV_KEY, EventCode.BTN_X }, "y" },
    };

    private struct GamepadInputMapping {
        string source_string;
        string destination_string;
    }

    private struct GamepadAxisMapping {
        bool positive_mapped;
        bool negative_mapped;
    }

    private GamepadInputMapping[] mappings;
    private Replay.Services.Gamepad.GamepadDPad[] dpads;
    private HashTable<string, GamepadAxisMapping?> axes;

    construct {
        mappings = new GamepadInputMapping[] {};
        dpads = new Replay.Services.Gamepad.GamepadDPad[] {};
        axes = new HashTable<string, GamepadAxisMapping?> (str_hash, str_equal);
    }

    public string build_sdl_string () {
        var sdl_string = "platform:Linux,";
        foreach (var mapping in mappings) {
            sdl_string += @"$(mapping.source_string):$(mapping.destination_string),";
        }
        return sdl_string;
    }

    public bool set_button_mapping (uint8 hardware_index, Replay.Services.Gamepad.GamepadInput source) {
        return add_destination (@"b$(hardware_index)", source);
    }

    public bool set_axis_mapping (uint8 hardware_index, int range, Replay.Services.Gamepad.GamepadInput source) {
        var destination = @"a$(hardware_index)";

        var positive = range >= 0;
        var negative = range <= 0;

        if (!(destination in axes)) {
            axes[destination] = { false, false };
        }

        var mapping = axes[destination];

        if ((positive && mapping.positive_mapped) || (negative && mapping.negative_mapped)) {
            return false;
        }

        axes[destination] = {
            mapping.positive_mapped || positive,
            mapping.negative_mapped || negative
        };

        if (range > 0) {
            return add_destination (@"+$(destination)", source);
        }
        if (range < 0) {
            return add_destination (@"-$(destination)", source);
        }
        return add_destination (destination, source);
    }

    public bool set_hat_mapping (uint8 hardware_index, int32 value, Replay.Services.Gamepad.GamepadInput source) {
        var dpad_index = hardware_index / 2;
        var dpad_axis = hardware_index % 2;

        while (dpads.length <= hardware_index) {
            dpads += Replay.Services.Gamepad.GamepadDPad ();
        }
        var dpad = dpads[dpad_index];
        var changed_value = value == 0 ? dpad.axis_values[dpad_axis] : value;
        dpad.axis_values[dpad_axis] = value;

        // Add 4 so the remainder is positive.
        var dpad_position = (changed_value + dpad_axis + 4) % 4;
        var dpad_position_2pow = Math.pow (2, dpad_position);

        return add_destination (@"h$(dpad_index).$(dpad_position_2pow)", source);
    }

    private bool add_destination (string destination_string, Replay.Services.Gamepad.GamepadInput source) {
        if (is_mapping_present (destination_string)) {
            return false;
        }

        var source_string = get_mapping_source (source);
        if (source_string == null) {
            critical ("Invalid input");
            return false;
        }

        GamepadInputMapping mapping = { source_string, destination_string };
        mappings += mapping;

        return true;
    }

    private bool is_mapping_present (string destination_string) {
        foreach (var mapping in mappings) {
            if (destination_string == mapping.destination_string) {
                return true;
            }
        }
        return false;
    }

    private string? get_mapping_source (Replay.Services.Gamepad.GamepadInput input) {
        foreach (var input_source in INPUT_SOURCES) {
            if (input == input_source.input) {
                return input_source.source;
            }
        }
        return null;
    }

}
