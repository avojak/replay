/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public enum Replay.Models.LibretroArtType {

    BOX,
    SCREENSHOT,
    TITLESCREEN;

    public string to_string () {
        switch (this) {
            case BOX:
                return "BOX";
            case SCREENSHOT:
                return "SCREENSHOT";
            case TITLESCREEN:
                return "TITLESCREEN";
            default:
                assert_not_reached ();
        }
    }

    public string get_url_parameter () {
        switch (this) {
            case BOX:
                return "Named_Boxarts";
            case SCREENSHOT:
                return "Named_Snaps";
            case TITLESCREEN:
                return "Named_Titles";
            default:
                assert_not_reached ();
        }
    }

}
