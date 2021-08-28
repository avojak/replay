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

public class Replay.DMG.IO.SerialPort : GLib.Object, Replay.DMG.Memory.AddressSpace {

    private const int SB_ADDRESS = 0xFF01;
    private const int SC_ADDRESS = 0xFF02;

    private int sb; // Serial transfer data
    private int sc; // Serial transfer control

    public SerialPort () {
    }

    public bool accepts (int address) {
        return address == SB_ADDRESS || address == SC_ADDRESS;
    }

    public int read_byte (int address) {
        if (address == SB_ADDRESS) {
            return sb;
        } else if (address == SC_ADDRESS) {
            return sc; // TODO: CoffeeGB has this bitwise OR'd with some constant byte...
        } else {
            assert_not_reached ();
        }
    }

    public void write_byte (int address, int value) {
        if (address == SB_ADDRESS) {
            sb = value;
        } else if (address == SC_ADDRESS) {
            sc = value;
        } else {
            assert_not_reached ();
        }
    }

}
