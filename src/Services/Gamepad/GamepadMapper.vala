/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/gamepad/gamepad-mapper.vala
public class Replay.Services.Gamepad.GamepadMapper : Replay.Services.DeviceMapper<string>, GLib.Object {

    private const double ANALOG_ANIMATION_SPEED = 166660.0;

    private unowned Manette.Device device;
    private unowned Replay.Views.GamepadView gamepad_view;

    private Replay.Services.Gamepad.GamepadInput[] mapping_inputs;
    private Replay.Services.Gamepad.GamepadInput input;
    private uint current_input_index = 0;
    private ulong gamepad_event_handler_id = 0;
    private uint tick_cb = 0;
    private uint64 animation_start_time = 0;
    private Replay.Services.Gamepad.GamepadMappingBuilder mapping_builder;

    public GamepadMapper (Manette.Device device, Replay.Services.Gamepad.GamepadViewConfiguration configuration,
        Replay.Views.GamepadView gamepad_view, Replay.Services.Gamepad.GamepadInput[] mapping_inputs) {
        this.device = device;
        this.gamepad_view = gamepad_view;
        this.mapping_inputs = mapping_inputs;
        gamepad_view.configuration = configuration;
    }

    public void start () {
        mapping_builder = new Replay.Services.Gamepad.GamepadMappingBuilder ();
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
        gamepad_event_handler_id = device.event.connect (on_device_event);
    }

    private void disconnect_from_device () {
        if (gamepad_event_handler_id != 0) {
            device.disconnect (gamepad_event_handler_id);
            gamepad_event_handler_id = 0;
        }
    }

    private void on_device_event (Manette.Event event) {
        switch (event.get_event_type ()) {
            case Manette.EventType.EVENT_BUTTON_RELEASE:
                if (input.type == EventCode.EV_ABS) {
                    return;
                }
                if (!mapping_builder.set_button_mapping ((uint8) event.get_hardware_index (), input)) {
                    return;
                }
                break;
            case Manette.EventType.EVENT_ABSOLUTE:
                uint16 axis;
                double value;
                if (!event.get_absolute (out axis, out value)) {
                    return;
                }
                if (-0.8 < value < 0.8) {
                    return;
                }
                int range = 0;
                if (input.code == EventCode.BTN_DPAD_UP ||
                    input.code == EventCode.BTN_DPAD_DOWN ||
                    input.code == EventCode.BTN_DPAD_LEFT ||
                    input.code == EventCode.BTN_DPAD_RIGHT) {
                    range = value > 0 ? 1 : -1;
                }
                if (!mapping_builder.set_axis_mapping ((uint8) event.get_hardware_index (), range, input)) {
                    return;
                }
                break;
            case Manette.EventType.EVENT_HAT:
                uint16 axis;
                int8 value;
                if (!event.get_hat (out axis, out value)) {
                    return;
                }
                if (value == 0) {
                    return;
                }
                if (!mapping_builder.set_hat_mapping ((uint8) event.get_hardware_index (), value, input)) {
                    return;
                }
                break;
            default:
                return;
        }

        next_input ();
    }

    private void next_input () {
        if (current_input_index == mapping_inputs.length) {
            var sdl_string = mapping_builder.build_sdl_string ();
            finished (sdl_string);
            return;
        }
        if (tick_cb != 0) {
            gamepad_view.remove_tick_callback (tick_cb);
            tick_cb = 0;
        }

        gamepad_view.reset ();
        input = mapping_inputs[current_input_index++];

        switch (input.type) {
            case EventCode.EV_KEY:
                gamepad_view.highlight (input, true);
                break;
            case EventCode.EV_ABS:
                animation_start_time = gamepad_view.get_frame_clock ().get_frame_time ();
                tick_cb = gamepad_view.add_tick_callback ((widget, clock) => {
                    var time = clock.get_frame_time () - animation_start_time;
                    double t = time / ANALOG_ANIMATION_SPEED;
                    gamepad_view.set_analog (input, Math.sin (t));
                    return GLib.Source.CONTINUE;
                });
                break;
            default:
                break;
        }

        update_info_message ();
    }

    private void update_info_message () {
        switch (input.type) {
            case EventCode.EV_KEY:
                prompt (_("Press the suitable button on your gamepad…"));
                break;
            case EventCode.EV_ABS:
                if (input.code == EventCode.ABS_X || input.code == EventCode.ABS_RX) {
                    prompt (_("Move the suitable axis left/right on your gamepad…"));
                } else if (input.code == EventCode.ABS_Y || input.code == EventCode.ABS_RY) {
                    prompt (_("Move the suitable axis up/down on your gamepad…"));
                }
                break;
            default:
                break;
        }
    }

}
