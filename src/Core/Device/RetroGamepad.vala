// This file is part of GNOME Games. License: GPL-3.0+.

private class Replay.Core.Device.RetroGamepad : GLib.Object, Retro.Controller {
	private const uint16 RUMBLE_DURATION_MS = int16.MAX;

	public Manette.Device device { get; construct; }

	private bool[] buttons;
	private int16[] axes;
	private uint16 rumble_effect[2];

	public RetroGamepad (Manette.Device device) {
		Object (device: device);
	}

	construct {
		buttons = new bool[EventCode.KEY_MAX + 1];
		axes = new int16[EventCode.ABS_MAX + 1];

		device.button_press_event.connect (on_button_press_event);
		device.button_release_event.connect (on_button_release_event);
		device.absolute_axis_event.connect (on_absolute_axis_event);
	}

	public int16 get_input_state (Retro.Input input) {
		switch (input.get_controller_type ()) {
		case Retro.ControllerType.JOYPAD:
			Retro.JoypadId id;
			if (!input.get_joypad (out id))
				return 0;

			return get_button_pressed (id) ? int16.MAX : 0;
		case Retro.ControllerType.ANALOG:
			Retro.AnalogId id;
			Retro.AnalogIndex index;
			if (!input.get_analog (out id, out index))
				return 0;

			return get_analog_value (index, id);
		default:
			return 0;
		}
	}

	public Retro.ControllerType get_controller_type () {
		return Retro.ControllerType.JOYPAD;
	}

	public uint64 get_capabilities () {
		return (1 << Retro.ControllerType.JOYPAD) | (1 << Retro.ControllerType.ANALOG);
	}

	public bool get_supports_rumble () {
		return device.has_rumble ();
	}

	public void set_rumble_state (Retro.RumbleEffect effect, uint16 strength) {
		rumble_effect[effect] = strength;

		device.rumble (rumble_effect[Retro.RumbleEffect.STRONG],
		               rumble_effect[Retro.RumbleEffect.WEAK],
		               RUMBLE_DURATION_MS);
	}

	private bool get_button_pressed (Retro.JoypadId button) {
		var button_code = button.to_button_code ();

		return button_code != EventCode.EV_MAX && buttons[button_code];
	}

	private int16 get_analog_value (Retro.AnalogIndex index, Retro.AnalogId id) {
		switch (index) {
		case Retro.AnalogIndex.LEFT:
			switch (id) {
			case Retro.AnalogId.X:
				return axes[EventCode.ABS_X];
			case Retro.AnalogId.Y:
				return axes[EventCode.ABS_Y];
			default:
				return 0;
			}
		case Retro.AnalogIndex.RIGHT:
			switch (id) {
			case Retro.AnalogId.X:
				return axes[EventCode.ABS_RX];
			case Retro.AnalogId.Y:
				return axes[EventCode.ABS_RY];
			default:
				return 0;
			}
		default:
			return 0;
		}
	}

	private void on_button_press_event (Manette.Event event) {
		uint16 button;

		if (event.get_button (out button)) {
			buttons[button] = true;
			emit_state_changed ();
		}
	}

	private void on_button_release_event (Manette.Event event) {
		uint16 button;

		if (event.get_button (out button)) {
			buttons[button] = false;
			emit_state_changed ();
		}
	}

	private void on_absolute_axis_event (Manette.Event event) {
		uint16 axis;
		double value;

		if (event.get_absolute (out axis, out value)) {
			axes[axis] = (int16) (value * int16.MAX);
			emit_state_changed ();
		}
	}
}
