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

public class Replay.DMG.Processor.FlagRegister : GLib.Object {

    // http://www.devrs.com/gb/files/opcodes.html

    private int byte;

    public int get_byte () {
        return byte;
    }

    public void set_byte (int value) {
        byte = value;
    }

    public void set_z (bool is_z) {
        update_byte (Replay.DMG.Processor.Flags.Z.get_bit_position (), is_z);
    }

    public void set_n (bool is_n) {
        update_byte (Replay.DMG.Processor.Flags.N.get_bit_position (), is_n);
    }

    public void set_h (bool is_h) {
        update_byte (Replay.DMG.Processor.Flags.H.get_bit_position (), is_h);
    }

    public void set_c (bool is_c) {
        update_byte (Replay.DMG.Processor.Flags.C.get_bit_position (), is_c);
    }

    private void update_byte (int position, bool value) {
        byte = Replay.Utils.BitUtils.update_bit (byte, position, value);
    }

    public bool is_z () {
        return Replay.Utils.BitUtils.get_bit (byte, Replay.DMG.Processor.Flags.Z.get_bit_position ());
    }

    public bool is_n () {
        return Replay.Utils.BitUtils.get_bit (byte, Replay.DMG.Processor.Flags.N.get_bit_position ());
    }

    public bool is_h () {
        return Replay.Utils.BitUtils.get_bit (byte, Replay.DMG.Processor.Flags.H.get_bit_position ());
    }

    public bool is_c () {
        return Replay.Utils.BitUtils.get_bit (byte, Replay.DMG.Processor.Flags.C.get_bit_position ());
    }

}
