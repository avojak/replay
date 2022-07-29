/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.GamepadSettingsPage : Replay.Views.Settings.InputDeviceSettingsPage<string> {

    private const Replay.Services.Gamepad.GamepadInput[] STANDARD_GAMEPAD_INPUTS = {
        { EventCode.EV_KEY, EventCode.BTN_EAST },
        { EventCode.EV_KEY, EventCode.BTN_SOUTH },
        { EventCode.EV_KEY, EventCode.BTN_WEST },
        { EventCode.EV_KEY, EventCode.BTN_NORTH },
        { EventCode.EV_KEY, EventCode.BTN_START },
        { EventCode.EV_KEY, EventCode.BTN_MODE },
        { EventCode.EV_KEY, EventCode.BTN_SELECT },
        { EventCode.EV_KEY, EventCode.BTN_THUMBL },
        { EventCode.EV_KEY, EventCode.BTN_THUMBR },
        { EventCode.EV_KEY, EventCode.BTN_TL },
        { EventCode.EV_KEY, EventCode.BTN_TR },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_UP },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_LEFT },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_DOWN },
        { EventCode.EV_KEY, EventCode.BTN_DPAD_RIGHT },
        { EventCode.EV_ABS, EventCode.ABS_X },
        { EventCode.EV_ABS, EventCode.ABS_Y },
        { EventCode.EV_ABS, EventCode.ABS_RX },
        { EventCode.EV_ABS, EventCode.ABS_RY },
        { EventCode.EV_KEY, EventCode.BTN_TL2 },
        { EventCode.EV_KEY, EventCode.BTN_TR2 }
    };

    public Manette.Device device { get; construct; }

    public GamepadSettingsPage (Manette.Device device) {
        Object (
            device: device
        );
    }

    public override Replay.Services.DeviceMapper<string> create_device_mapper () {
        return new Replay.Services.Gamepad.GamepadMapper (device,
            Replay.Services.Gamepad.GamepadViewConfiguration.get_default (),
            gamepad_view, STANDARD_GAMEPAD_INPUTS);
    }

    public override Replay.Services.DeviceTester create_device_tester () {
        return new Replay.Services.Gamepad.GamepadTester (device,
            Replay.Services.Gamepad.GamepadViewConfiguration.get_default (),
            gamepad_view);
    }

    public override bool has_user_mapping () {
        return device.has_user_mapping ();
    }

    public override void save_user_mapping (string sdl_string) {
        device.save_user_mapping (sdl_string);
    }

    public override void remove_user_mapping () {
        device.remove_user_mapping ();
    }

}
