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

public class Replay.DMG.Audio.SoundRegisters : GLib.Object, Replay.DMG.Memory.AddressSpace {

    private int[] space;

    public SoundRegisters () {
    }

    public bool accepts (int address) {
        bool sound_mode_1 = address >= 0xFF10 && address <= 0xFF14;
        bool sound_mode_2 = address >= 0xFF15 && address <= 0xFF19;
        bool sound_mode_3 = address >= 0xFF1a && address <= 0xFF1E;
        bool sound_mode_4 = address >= 0xFF1F && address <= 0xFF23;
        return sound_mode_1 || sound_mode_2 || sound_mode_3 || sound_mode_4;
    }

    public int read_byte (int address) {
        return -1;
    }

    public void write_byte (int address, int value) {

    }

}
