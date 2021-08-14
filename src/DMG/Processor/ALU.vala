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

public class Replay.DMG.Processor.ALU : GLib.Object {

    // ALU = Arithmetic Logic Unit

    // http://www.devrs.com/gb/files/opcodes.html

    private unowned Replay.DMG.Processor.Registers registers;

    public ALU (Replay.DMG.Processor.Registers registers) {
        Object (
            registers: registers
        );
    }

    public int inc (int value) {
        if ((value & 0x0F) == 0x0F) {
            registers.set_flag (Replay.DMG.Processor.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.Flags.H);
        }
        value++;
        if (value) {
            registers.clear_flag (Replay.DMG.Processor.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.Flags.Z);
        }
        registers.clear_flag (Replay.DMG.Processor.Flags.N);
        return value;
    }

    public int dec (int value) {
        if (value & 0x0F) {
            registers.clear_flag (Replay.DMG.Processor.Flags.H);
        } else {
            registers.set_flag (Replay.DMG.Processor.Flags.H);
        }
        value--;
        if (value) {
            registers.clear_flag (Replay.DMG.Processor.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.Flags.Z);
        }
        registers.set_flag (Replay.DMG.Processor.Flags.N);
        return value;
    }

}
