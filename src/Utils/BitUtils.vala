/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Replay.Utils.BitUtils : GLib.Object {

    public static int update_bit (int byte_value, int position, bool value) {
        return value ? set_bit (byte_value, position) : clear_bit (byte_value, position);
    }

    public static int set_bit (int byte_value, int position) {
        return (byte_value | (1 << position)) & 0xFF;
    }

    public static int clear_bit (int byte_value, int position) {
        return ~(1 << position) & byte_value & 0xFF;
    }

    public static bool get_bit (int byte_value, int position) {
        return (byte_value & (1 << position)) != 0;
    }

    // TODO: Don't really need this if we use a char for a byte
    public static int check_byte_argument (int value, string name = "byte") {
        if (value < 0 || value > 0xFF) {
            error ("The argument \"%s\" is not a valid byte value: %d", name, value);
        }
        return value;
    }

    // TODO: Don't really need this if we use a short for a word
    public static int check_word_argument (int value, string name = "word") {
        if (value < 0 || value > 0xFFFF) {
            error ("The argument \"%s\" is not a valid word value: %d", name, value);
        }
        return value;
    }

    public static int get_msb (int word) {
        check_word_argument (word);
        return word >> 8;
    }

    public static int get_lsb (int word) {
        check_word_argument (word);
        return word & 0xFF;
    }

}
