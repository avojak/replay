/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.Settings : GLib.Settings {

    public bool prefer_dark_style {
        get { return get_boolean ("prefer-dark-style"); }
        set { set_boolean ("prefer-dark-style", value); }
    }

    public int pos_x {
        get { return get_int ("pos-x"); }
        set { set_int ("pos-x", value); }
    }

    public int pos_y {
        get { return get_int ("pos-y"); }
        set { set_int ("pos-y", value); }
    }

    public int window_width {
        get { return get_int ("window-width"); }
        set { set_int ("window-width", value); }
    }

    public int window_height {
        get { return get_int ("window-height"); }
        set { set_int ("window-height", value); }
    }

    public int emu_pos_x {
        get { return get_int ("emu-pos-x"); }
        set { set_int ("emu-pos-x", value); }
    }

    public int emu_pos_y {
        get { return get_int ("emu-pos-y"); }
        set { set_int ("emu-pos-y", value); }
    }

    public int emu_window_width {
        get { return get_int ("emu-window-width"); }
        set { set_int ("emu-window-width", value); }
    }

    public int emu_window_height {
        get { return get_int ("emu-window-height"); }
        set { set_int ("emu-window-height", value); }
    }

    public bool emu_window_fullscreen {
        get { return get_boolean ("emu-window-fullscreen"); }
        set { set_boolean ("emu-window-fullscreen", value); }
    }

    public bool emu_boot_bios {
        get { return get_boolean ("emu-boot-bios"); }
        set { set_boolean ("emu-boot-bios", value); }
    }

    public string emu_default_filter {
        owned get { return get_string ("emu-default-filter"); }
        set { set_string ("emu-default-filter", value); }
    }

    public double emu_default_speed {
        get { return get_double ("emu-default-speed"); }
        set { set_double ("emu-default-speed", value); }
    }

    public string user_rom_directory {
        owned get { return get_string ("user-rom-directory"); }
        set { set_string ("user-rom-directory", value); }
    }

    public string user_save_directory {
        owned get { return get_string ("user-save-directory"); }
        set { set_string ("user-save-directory", value); }
    }

    public bool download_boxart {
        get { return get_boolean ("download_boxart"); }
        set { set_boolean ("download_boxart", value); }
    }

    public bool handle_window_focus_change {
        get { return get_boolean ("handle-window-focus-change"); }
        set { set_boolean ("handle-window-focus-change", value); }
    }

    public Settings () {
        Object (schema_id: Constants.APP_ID);
    }

}
