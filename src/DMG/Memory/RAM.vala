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

public class Replay.DMG.Memory.RAM : GLib.Object, Replay.DMG.Memory.AddressSpace {

    public int offset { get; construct; }
    public int length { get; construct; }
    private int[] space;

    public RAM (int offset, int length) {
        Object (
            offset: offset,
            length: length
        );
        space = new int[length];
    }

    public bool accepts (int address) {
        return address >= offset && address < offset + length;
    }

    public int read_byte (int address) {
        int index = address - offset;
        if (index < 0 || index >= space.length) {
            error ("Requested address is out of bounds");
        }
        return space[index];
    }

    public void write_byte (int address, int value) {
        int index = address - offset;
        if (index < 0 || index >= space.length) {
            error ("Target address is out of bounds");
        }
        space[index] = value;
    }

}
