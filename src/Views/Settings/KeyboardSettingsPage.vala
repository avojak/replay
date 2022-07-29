/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.KeyboardSettingsPage : Replay.Views.Settings.InputDeviceSettingsPage<Retro.KeyJoypadMapping> {

    private const Replay.Services.Gamepad.GamepadInput[] KEYBOARD_GAMEPAD_INPUTS = {
        { EventCode.EV_KEY, EventCode.BTN_EAST },
        { EventCode.EV_KEY, EventCode.BTN_SOUTH },
        { EventCode.EV_KEY, EventCode.BTN_WEST },
        { EventCode.EV_KEY, EventCode.BTN_NORTH },
        { EventCode.EV_KEY, EventCode.BTN_START },
        { EventCode.EV_KEY, EventCode.BTN_SELECT },
        { EventCode.EV_KEY, EventCode.BTN_THUMBL },
        { EventCode.EV_KEY, EventCode.BTN_THUMBR },
        { EventCode.EV_KEY, EventCode.BTN_TL },
        { EventCode.EV_KEY, EventCode.BTN_TR },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_UP },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_LEFT },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_DOWN },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_RIGHT },
        { EventCode.EV_KEY, EventCode.BTN_TL2 },
        { EventCode.EV_KEY, EventCode.BTN_TR2 },
    };

    public Replay.Services.Keyboard.KeyboardMappingManager mapping_manager { get; construct; }

    public KeyboardSettingsPage (Replay.Services.Keyboard.KeyboardMappingManager mapping_manager) {
        Object (
            mapping_manager: mapping_manager
        );
    }

    construct {
        //  action_area.pack_end (new Gtk.Button.from_icon_name ("input-keyboard"));
    }

    public override Replay.Services.DeviceMapper<Retro.KeyJoypadMapping> create_device_mapper () {
        return new Replay.Services.Keyboard.KeyboardMapper (
            Replay.Services.Gamepad.GamepadViewConfiguration.get_default (),
            gamepad_view, KEYBOARD_GAMEPAD_INPUTS);
    }

    public override Replay.Services.DeviceTester create_device_tester () {
        var tester = new Replay.Services.Keyboard.KeyboardTester (
            Replay.Services.Gamepad.GamepadViewConfiguration.get_default (),
            gamepad_view);
        tester.mapping = mapping_manager.mapping;
        mapping_manager.changed.connect (() => {
            tester.mapping = mapping_manager.mapping;
        });
        return tester;
    }

    public override bool has_user_mapping () {
        return !mapping_manager.is_default ();
    }

    public override void save_user_mapping (Retro.KeyJoypadMapping mapping) {
        mapping_manager.save_mapping (mapping);
    }

    public override void remove_user_mapping () {
        mapping_manager.delete_mapping ();
    }

}
