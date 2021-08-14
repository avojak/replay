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

public class Replay.DMG.Memory.MMU : GLib.Object {

    // http://gameboy.mongenel.com/dmg/asmmemmap.html
    // GameBoy Memory Areas
    // $FFFF	    Interrupt Enable Flag
    // $FF80-$FFFE	Zero Page - 127 bytes
    // $FF00-$FF7F	Hardware I/O Registers
    // $FEA0-$FEFF	Unusable Memory
    // $FE00-$FE9F	OAM - Object Attribute Memory
    // $E000-$FDFF	Echo RAM - Reserved, Do Not Use
    // $D000-$DFFF	Internal RAM - Bank 1-7 (switchable - CGB only)
    // $C000-$CFFF	Internal RAM - Bank 0 (fixed)
    // $A000-$BFFF	Cartridge RAM (If Available)
    // $9C00-$9FFF	BG Map Data 2
    // $9800-$9BFF	BG Map Data 1
    // $8000-$97FF	Character RAM
    // $4000-$7FFF	Cartridge ROM - Switchable Banks 1-xx
    // $0150-$3FFF	Cartridge ROM - Bank 0 (fixed)
    // $0100-$014F	Cartridge Header Area
    // $0000-$00FF	Restart and Interrupt Vectors

    char cart[0x8000]; // $0000-$7FFF  Cart RAM
    char sram[0x2000]; // $A000-$BFFF  External (Cartridge) RAM
    char io[0x100];    // $FF00-$FF7F  Hardware I/O Registers
    char vram[0x2000]; // $8000-$9FFF  VRAM
    char oam[0x100];   // $FE00-$FEFF  Object Attribute Memory (OAM)
    char wram[0x2000]; // $C000-$FDFF  Internal Work RAM (WRAM)
    char hram[0x80];   // $FF80-$FFFE  High RAM Area

    public void write_byte (int address, int value) {
        // TODO
    }

    public void read_byte (int address) {
        // TODO
    }

}
