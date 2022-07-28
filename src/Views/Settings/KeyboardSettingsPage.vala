/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.KeyboardSettingsPage : Replay.Views.Settings.InputDeviceSettingsPage<Retro.KeyJoypadMapping> {

    public override Replay.Services.DeviceMapper<Retro.KeyJoypadMapping> create_device_mapper () {
        return new Replay.Services.Keyboard.KeyboardMapper (
            Replay.Services.Gamepad.GamepadViewConfiguration.get_default (),
            gamepad_view, STANDARD_GAMEPAD_INPUTS);
    }

    public override Replay.Services.DeviceTester create_device_tester () {
        return new Replay.Services.Keyboard.KeyboardTester (
            Replay.Services.Gamepad.GamepadViewConfiguration.get_default (),
            gamepad_view);
    }

    public override bool has_user_mapping () {
        // TODO
        return false;
    }

    public override void save_user_mapping (Retro.KeyJoypadMapping mapping) {
        // TODO
    }

    public override void remove_user_mapping () {
        // TODO
    }

}
