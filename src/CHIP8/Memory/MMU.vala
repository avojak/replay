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

public class Replay.CHIP8.Memory.MMU : GLib.Object {

	//  public const int FONT_OFFSET = 0x50;
	public const uint16 ROM_SIZE = 0x1000; // 4096 bytes
	public const uint16 ROM_OFFSET = 0x200;
	public const uint16 MAX_ROM_SIZE = ROM_SIZE - ROM_OFFSET;
	public const uint8 FONT_SPRITE_SIZE = 5; // Each sprite is 5 bytes

    private const uint8 FONT_SPRITES[80] = {
		0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
		0x20, 0x60, 0x20, 0x20, 0x70, // 1
		0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
		0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
		0x90, 0x90, 0xF0, 0x10, 0x10, // 4
		0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
		0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
		0xF0, 0x10, 0x20, 0x40, 0x40, // 7
		0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
		0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
		0xF0, 0x90, 0xF0, 0x90, 0x90, // A
		0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
		0xF0, 0x80, 0x80, 0x80, 0xF0, // C
		0xE0, 0x90, 0x90, 0x90, 0xE0, // D
		0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
		0xF0, 0x80, 0xF0, 0x80, 0x80  // F
    };

    private uint8[] data = new uint8[ROM_SIZE];

    construct {
		// Clear data
        for (int i = 0; i < data.length; i++) {
            data[i] = 0;
        }
        // Load font sprites into memory
        for (int i = 0; i < FONT_SPRITES.length; i++) {
            data[i] = FONT_SPRITES[i];
        }
    }

    public uint8 get_byte (int address) {
		if (address < 0 || address >= data.length) {
			critical ("Invalid memory address: 0x%04X", address);
		}
        return data[address];
    }

    public void set_byte (int address, uint8 value) {
		if (address < 0 || address >= data.length) {
			critical ("Invalid memory address: 0x%04X", address);
			return;
		}
        data[address] = value;
    }

}