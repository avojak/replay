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

public class Replay.DMG.Processor.InterruptManager : GLib.Object, Replay.DMG.Memory.AddressSpace {

    private const int INTERRUPT_ENABLE_ADDRESS = 0xFFFF;
    private const int INTERRUPT_FLAG_ADDRESS = 0xFF0F;

    public InterruptManager () {
    }

    public bool accepts (int address) {
        return address == INTERRUPT_ENABLE_ADDRESS || address == INTERRUPT_FLAG_ADDRESS;
    }

    public int read_byte (int address) {
        return -1;
    }

    public void write_byte (int address, int value) {

    }

}
