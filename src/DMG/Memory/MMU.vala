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

    // TODO: These should probably be char arrays since, well, you know, a char is a byte, not an int...

    int cart[0x8000]; // $0000-$7FFF  Cart RAM
    int vram[0x2000]; // $8000-$9FFF  VRAM
    int sram[0x2000]; // $A000-$BFFF  External (Cartridge) RAM
    int wram[0x2000]; // $C000-$FDFF  Internal Work RAM (WRAM)
    int oam[0x100];   // $FE00-$FEFF  Object Attribute Memory (OAM)
    int io[0x100];    // $FF00-$FF7F  Hardware I/O Registers
    int hram[0x80];   // $FF80-$FFFE  High RAM Area

    private Gee.List<Replay.DMG.Memory.AddressSpace> address_spaces;

    construct {
        address_spaces = new Gee.ArrayList<Replay.DMG.Memory.AddressSpace> ();
        //  address_spaces.add (new CartRAM ());
    }

    public void initialize_io_registers () {
        // Hardware I/O
        write_byte (0xFF05, 0x00);
        write_byte (0xFF06, 0x00);
        write_byte (0xFF07, 0x00);
        write_byte (0xFF10, 0x80);
        write_byte (0xFF11, 0xBF);
        write_byte (0xFF12, 0xF3);
        write_byte (0xFF14, 0xBF);
        write_byte (0xFF16, 0x3F);
        write_byte (0xFF17, 0x00);
        write_byte (0xFF19, 0xBF);
        write_byte (0xFF1A, 0x7A);
        write_byte (0xFF1B, 0xFF);
        write_byte (0xFF1C, 0x9F);
        write_byte (0xFF1E, 0xBF);
        write_byte (0xFF20, 0xFF);
        write_byte (0xFF21, 0x00);
        write_byte (0xFF22, 0x00);
        write_byte (0xFF23, 0xBF);
        write_byte (0xFF24, 0x77);
        write_byte (0xFF25, 0xF3);
        write_byte (0xFF26, 0xF1);
        write_byte (0xFF40, 0x91);
        write_byte (0xFF42, 0x00);
        write_byte (0xFF43, 0x00);
        write_byte (0xFF45, 0x00);
        write_byte (0xFF47, 0xFC);
        write_byte (0xFF48, 0xFF);
        write_byte (0xFF49, 0xFF);
        write_byte (0xFF4A, 0x00);
        write_byte (0xFF4B, 0x00);
        // Disable interrupt
        // TODO: Should this be done elsewhere?
        write_byte (0xFFFF, 0x00);
    }

    public void write_byte (int address, int value) {
        //  if (address < 0x8000) {
        //      error ("Cannot write to cart address space!");
        //  } else if (address >= 0x8000 && address <= 0x9FF) {
        //      // VRAM
        //  } else if (address >= 0xA000 && address <= 0xBFFF) {
        //      // SRAM
        //  } else if (address >= 0xC000 && address <= 0xFDFF) {
        //      // WRAM
        //  } else if (address >= 0xFE00 && address <= 0xFEFF) {
        //      // OAM
        //  } else if (address >= 0xFF00 && address <= 0xFF7F) {
        //      // IO
        //  } else if (address >= 0xFF80 && address <= 0xFFFE) {
        //      // HRAM
        //  } else if (address == 0xFFFF) {
        //      // Interrupt
        //  } else {
        //      error ("Cannot write to memory address %d", address);
        //  }
        foreach (var address_space in address_spaces) {
            if (address_space.accepts (address)) {
                address_space.write_byte (address, value);
                return;
            }
        }
        warning ("No address space found for address: %d", address);
    }

    public int read_byte (int address) {
        foreach (var address_space in address_spaces) {
            if (address_space.accepts (address)) {
                return address_space.read_byte (address);
            }
        }
        warning ("No address space found for address: %d", address);
        return -1;
    }

    public int read_word (int address) {
        // TODO
        return -1;
    }

}
