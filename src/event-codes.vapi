// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "linux/input-event-codes.h", cprefix = "", lower_case_cprefix = "")]
namespace EventCode {
    public const uint16 EV_KEY;
    public const uint16 EV_ABS;
    public const uint16 EV_MAX;

    public const uint16 BTN_SOUTH;
    public const uint16 BTN_EAST;
    public const uint16 BTN_WEST;
    public const uint16 BTN_NORTH;

    public const uint16 BTN_A;
    public const uint16 BTN_B;
    public const uint16 BTN_X;
    public const uint16 BTN_Y;
    public const uint16 BTN_TL;
    public const uint16 BTN_TR;
    public const uint16 BTN_TL2;
    public const uint16 BTN_TR2;
    public const uint16 BTN_SELECT;
    public const uint16 BTN_START;
    public const uint16 BTN_MODE;
    public const uint16 BTN_THUMBL;
    public const uint16 BTN_THUMBR;
    public const uint16 BTN_DPAD_UP;
    public const uint16 BTN_DPAD_DOWN;
    public const uint16 BTN_DPAD_LEFT;
    public const uint16 BTN_DPAD_RIGHT;
    public const uint16 KEY_MAX;

    public const uint16 ABS_X;
    public const uint16 ABS_Y;
    public const uint16 ABS_RX;
    public const uint16 ABS_RY;
    public const uint16 ABS_MAX;
}
