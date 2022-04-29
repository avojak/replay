/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
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
