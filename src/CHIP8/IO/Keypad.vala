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

public class Replay.CHIP8.IO.Keypad : GLib.Object {

    public static uint8[] KEYS = new uint8[] {
        0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF
    };

    // TODO: This should be configurable
    public static Gee.Map<char, uint8> KEYPAD_MAPPING;

    private Gee.Map<uint8, bool> key_states;

    static construct {
        KEYPAD_MAPPING = new Gee.HashMap<char, uint8> ();
        KEYPAD_MAPPING.set ('1', 0x1);
        KEYPAD_MAPPING.set ('2', 0x2);
        KEYPAD_MAPPING.set ('3', 0x3);
        KEYPAD_MAPPING.set ('4', 0xC);
        KEYPAD_MAPPING.set ('Q', 0x4);
        KEYPAD_MAPPING.set ('W', 0x5);
        KEYPAD_MAPPING.set ('E', 0x6);
        KEYPAD_MAPPING.set ('R', 0xD);
        KEYPAD_MAPPING.set ('A', 0x7);
        KEYPAD_MAPPING.set ('S', 0x8);
        KEYPAD_MAPPING.set ('D', 0x9);
        KEYPAD_MAPPING.set ('F', 0xE);
        KEYPAD_MAPPING.set ('Z', 0xA);
        KEYPAD_MAPPING.set ('X', 0x0);
        KEYPAD_MAPPING.set ('C', 0xB);
        KEYPAD_MAPPING.set ('V', 0xF);
    }

    construct {
        key_states = new Gee.HashMap<uint8, bool> ();
        foreach (uint8 key in KEYS) {
            key_states.set (key, false);
        }
    }

    public void key_pressed (uint8 key) {
        key_states.set (key, true);
    }

    public void key_released (uint8 key) {
        key_states.set (key, false);
    }

    public bool is_key_pressed (uint8 key) {
        return key_states.get (key);
    }

    public uint8? get_key_presssed () {
        foreach (var entry in key_states.entries) {
            if (entry.value) {
                return entry.key;
            }
        }
        return null;
    }

}