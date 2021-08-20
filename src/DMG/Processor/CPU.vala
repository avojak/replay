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

public class Replay.DMG.Processor.CPU : GLib.Object {
    
    /**
     * ALU = Arithmetic Logic Unit
     * 
     */

    // http://imrannazar.com/Gameboy-Z80-Opcode-Map
    // https://www.pastraiser.com/cpu/gameboy/gameboy_opcodes.html
    // http://www.devrs.com/gb/files/opcodes.html
    // http://bgb.bircd.org/pandocs.htm
    // https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf

    private static Replay.DMG.Processor.Operation[] operations;

    private unowned Replay.DMG.Memory.MMU mmu;
    private Replay.DMG.Processor.ALU alu;
    private Replay.DMG.Processor.Registers registers;

    public CPU (Replay.DMG.Memory.MMU mmu) {
        this.mmu = mmu;
    }

    static construct {
        operations = new Replay.DMG.Processor.Operation[256];
        operations[0x00] = new Replay.DMG.Processor.Operation ("NOP", (cpu) => { cpu.nop (); }, 1, 4);
        operations[0x01] = new Replay.DMG.Processor.Operation ("LD BC, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.BC, cpu.d16 ()); }, 3, 12);
        operations[0x02] = new Replay.DMG.Processor.Operation ("LD (BC), A", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.BC, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        operations[0x03] = new Replay.DMG.Processor.Operation ("INC BC", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        operations[0x04] = new Replay.DMG.Processor.Operation ("INC B", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x05] = new Replay.DMG.Processor.Operation ("DEC B", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x06] = new Replay.DMG.Processor.Operation ("LD B, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.B, cpu.d8 ()); }, 2, 8);
        operations[0x07] = new Replay.DMG.Processor.Operation ("RLCA", (cpu) => { cpu.rlca (); }, 1, 4);
        operations[0x08] = null; // new Replay.DMG.Processor.Operation ("LD (a16), SP", (cpu) => {  }, 3, 20);
        operations[0x09] = new Replay.DMG.Processor.Operation ("ADD HL, BC", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        operations[0x0A] = new Replay.DMG.Processor.Operation ("LD A, (BC)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        operations[0x0B] = new Replay.DMG.Processor.Operation ("DEC BC", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        operations[0x0C] = new Replay.DMG.Processor.Operation ("INC C", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x0D] = new Replay.DMG.Processor.Operation ("DEC C", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x0E] = new Replay.DMG.Processor.Operation ("LD C, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.C, cpu.d8 ()); }, 2, 8);
        operations[0x0F] = new Replay.DMG.Processor.Operation ("RRCA", (cpu) => { cpu.rrca (); }, 1, 4);
        operations[0x10] = new Replay.DMG.Processor.Operation ("STOP", (cpu) => { cpu.stop (); }, 2, 4);
        operations[0x11] = new Replay.DMG.Processor.Operation ("LD DE, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.DE, cpu.d16 ()); }, 3, 12);
        operations[0x12] = null; // TODO
        operations[0x13] = new Replay.DMG.Processor.Operation ("INC DE", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        operations[0x14] = new Replay.DMG.Processor.Operation ("INC D", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x15] = new Replay.DMG.Processor.Operation ("DEC D", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x16] = new Replay.DMG.Processor.Operation ("LD D, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.D, cpu.d8 ()); }, 2, 8);
        operations[0x17] = new Replay.DMG.Processor.Operation ("RLA", (cpu) => { cpu.rla (); }, 1, 4);
        operations[0x18] = null; // TODO
        operations[0x19] = new Replay.DMG.Processor.Operation ("ADD HL, DE", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        operations[0x1A] = new Replay.DMG.Processor.Operation ("LD A, (DE)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        operations[0x1B] = null; // TODO
        operations[0x1C] = new Replay.DMG.Processor.Operation ("INC E", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x1D] = new Replay.DMG.Processor.Operation ("DEC E", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x1E] = null; // TODO
        operations[0x1F] = null; // TODO
        operations[0x20] = null; // TODO
        operations[0x21] = new Replay.DMG.Processor.Operation ("LD HL, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.HL, cpu.d16 ()); }, 3, 12);
        operations[0x22] = null; // TODO
        operations[0x23] = new Replay.DMG.Processor.Operation ("INC HL", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x24] = new Replay.DMG.Processor.Operation ("INC H", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x25] = new Replay.DMG.Processor.Operation ("DEC H", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x26] = null; // TODO
        operations[0x27] = null; // TODO
        operations[0x28] = null; // TODO
        operations[0x29] = new Replay.DMG.Processor.Operation ("ADD HL, HL", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x2A] = null; // TODO
        operations[0x2B] = null; // TODO
        operations[0x2C] = new Replay.DMG.Processor.Operation ("INC L", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x2D] = new Replay.DMG.Processor.Operation ("DEC L", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x2E] = null; // TODO
        operations[0x2F] = null; // TODO
        operations[0x30] = null; // TODO
        operations[0x31] = null; // TODO
        operations[0x32] = null; // TODO
        operations[0x33] = null; // TODO
        operations[0x34] = null; // TODO
        operations[0x35] = null; // TODO
        operations[0x36] = null; // TODO
        operations[0x37] = null; // TODO
        operations[0x38] = null; // TODO
        operations[0x39] = null; // TODO
        operations[0x3A] = null; // TODO
        operations[0x3B] = null; // TODO
        operations[0x3C] = new Replay.DMG.Processor.Operation ("INC A", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x3D] = new Replay.DMG.Processor.Operation ("DEC A", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x3E] = null; // TODO
        operations[0x3F] = null; // TODO
        operations[0x40] = new Replay.DMG.Processor.Operation ("LD B, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x41] = new Replay.DMG.Processor.Operation ("LD B, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x42] = new Replay.DMG.Processor.Operation ("LD B, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x43] = new Replay.DMG.Processor.Operation ("LD B, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x44] = new Replay.DMG.Processor.Operation ("LD B, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x45] = new Replay.DMG.Processor.Operation ("LD B, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x46] = new Replay.DMG.Processor.Operation ("LD B, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x47] = new Replay.DMG.Processor.Operation ("LD B, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x48] = new Replay.DMG.Processor.Operation ("LD C, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x49] = new Replay.DMG.Processor.Operation ("LD C, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x4A] = new Replay.DMG.Processor.Operation ("LD C, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x4B] = new Replay.DMG.Processor.Operation ("LD C, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x4C] = new Replay.DMG.Processor.Operation ("LD C, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x4D] = new Replay.DMG.Processor.Operation ("LD C, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x4E] = new Replay.DMG.Processor.Operation ("LD C, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x4F] = new Replay.DMG.Processor.Operation ("LD C, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x50] = new Replay.DMG.Processor.Operation ("LD D, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x51] = new Replay.DMG.Processor.Operation ("LD D, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x52] = new Replay.DMG.Processor.Operation ("LD D, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x53] = new Replay.DMG.Processor.Operation ("LD D, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x54] = new Replay.DMG.Processor.Operation ("LD D, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x55] = new Replay.DMG.Processor.Operation ("LD D, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x56] = new Replay.DMG.Processor.Operation ("LD D, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x57] = new Replay.DMG.Processor.Operation ("LD D, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x58] = new Replay.DMG.Processor.Operation ("LD E, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x59] = new Replay.DMG.Processor.Operation ("LD E, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x5A] = new Replay.DMG.Processor.Operation ("LD E, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x5B] = new Replay.DMG.Processor.Operation ("LD E, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x5C] = new Replay.DMG.Processor.Operation ("LD E, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x5D] = new Replay.DMG.Processor.Operation ("LD E, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x5E] = new Replay.DMG.Processor.Operation ("LD E, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x5F] = new Replay.DMG.Processor.Operation ("LD E, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x60] = new Replay.DMG.Processor.Operation ("LD H, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x61] = new Replay.DMG.Processor.Operation ("LD H, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x62] = new Replay.DMG.Processor.Operation ("LD H, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x63] = new Replay.DMG.Processor.Operation ("LD H, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x64] = new Replay.DMG.Processor.Operation ("LD H, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x65] = new Replay.DMG.Processor.Operation ("LD H, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x66] = new Replay.DMG.Processor.Operation ("LD H, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x67] = new Replay.DMG.Processor.Operation ("LD H, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x68] = new Replay.DMG.Processor.Operation ("LD L, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x69] = new Replay.DMG.Processor.Operation ("LD L, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x6A] = new Replay.DMG.Processor.Operation ("LD L, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x6B] = new Replay.DMG.Processor.Operation ("LD L, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x6C] = new Replay.DMG.Processor.Operation ("LD L, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x6D] = new Replay.DMG.Processor.Operation ("LD L, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x6E] = new Replay.DMG.Processor.Operation ("LD L, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x6F] = new Replay.DMG.Processor.Operation ("LD L, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x70] = null; // TODO
        operations[0x71] = null; // TODO
        operations[0x72] = null; // TODO
        operations[0x73] = null; // TODO
        operations[0x74] = null; // TODO
        operations[0x75] = null; // TODO
        operations[0x76] = new Replay.DMG.Processor.Operation ("HALT", (cpu) => { cpu.halt (); }, 1, 4);
        operations[0x77] = null; // TODO
        operations[0x78] = new Replay.DMG.Processor.Operation ("LD A, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x79] = new Replay.DMG.Processor.Operation ("LD A, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x7A] = new Replay.DMG.Processor.Operation ("LD A, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x7B] = new Replay.DMG.Processor.Operation ("LD A, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x7C] = new Replay.DMG.Processor.Operation ("LD A, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x7D] = new Replay.DMG.Processor.Operation ("LD A, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x7E] = new Replay.DMG.Processor.Operation ("LD A, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x7F] = new Replay.DMG.Processor.Operation ("LD A, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x80] = new Replay.DMG.Processor.Operation ("ADD A, B", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x81] = new Replay.DMG.Processor.Operation ("ADD A, C", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x82] = new Replay.DMG.Processor.Operation ("ADD A, D", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x83] = new Replay.DMG.Processor.Operation ("ADD A, E", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x84] = new Replay.DMG.Processor.Operation ("ADD A, H", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x85] = new Replay.DMG.Processor.Operation ("ADD A, L", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x86] = null; // TODO
        operations[0x87] = new Replay.DMG.Processor.Operation ("ADD A, A", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x88] = new Replay.DMG.Processor.Operation ("ADC A, B", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x89] = null; // TODO
        operations[0x8A] = null; // TODO
        operations[0x8B] = null; // TODO
        operations[0x8C] = null; // TODO
        operations[0x8D] = null; // TODO
        operations[0x8E] = null; // TODO
        operations[0x8F] = null; // TODO
        operations[0x90] = null; // TODO
        operations[0x91] = null; // TODO
        operations[0x92] = null; // TODO
        operations[0x93] = null; // TODO
        operations[0x94] = null; // TODO
        operations[0x95] = null; // TODO
        operations[0x96] = null; // TODO
        operations[0x97] = null; // TODO
        operations[0x98] = null; // TODO
        operations[0x99] = null; // TODO
        operations[0x9A] = null; // TODO
        operations[0x9B] = null; // TODO
        operations[0x9C] = null; // TODO
        operations[0x9D] = null; // TODO
        operations[0x9E] = null; // TODO
        operations[0x9F] = null; // TODO
        operations[0xA0] = null; // TODO
        operations[0xA1] = null; // TODO
        operations[0xA2] = null; // TODO
        operations[0xA3] = null; // TODO
        operations[0xA4] = null; // TODO
        operations[0xA5] = null; // TODO
        operations[0xA6] = null; // TODO
        operations[0xA7] = null; // TODO
        operations[0xA8] = null; // TODO
        operations[0xA9] = null; // TODO
        operations[0xAA] = null; // TODO
        operations[0xAB] = null; // TODO
        operations[0xAC] = null; // TODO
        operations[0xAD] = null; // TODO
        operations[0xAE] = null; // TODO
        operations[0xAF] = null; // TODO
        operations[0xB0] = null; // TODO
        operations[0xB1] = null; // TODO
        operations[0xB2] = null; // TODO
        operations[0xB3] = null; // TODO
        operations[0xB4] = null; // TODO
        operations[0xB5] = null; // TODO
        operations[0xB6] = null; // TODO
        operations[0xB7] = null; // TODO
        operations[0xB8] = null; // TODO
        operations[0xB9] = null; // TODO
        operations[0xBA] = null; // TODO
        operations[0xBB] = null; // TODO
        operations[0xBC] = null; // TODO
        operations[0xBD] = null; // TODO
        operations[0xBE] = null; // TODO
        operations[0xBF] = null; // TODO
        operations[0xC0] = null; // TODO
        operations[0xC1] = null; // TODO
        operations[0xC2] = null; // TODO
        operations[0xC3] = null; // TODO
        operations[0xC4] = null; // TODO
        operations[0xC5] = null; // TODO
        operations[0xC6] = null; // TODO
        operations[0xC7] = null; // TODO
        operations[0xC8] = null; // TODO
        operations[0xC9] = null; // TODO
        operations[0xCA] = null; // TODO
        operations[0xCB] = null; // TODO
        operations[0xCC] = null; // TODO
        operations[0xCD] = null; // TODO
        operations[0xCE] = null; // TODO
        operations[0xCF] = null; // TODO
        operations[0xD0] = null; // TODO
        operations[0xD1] = null; // TODO
        operations[0xD2] = null; // TODO
        operations[0xD3] = null; // TODO
        operations[0xD4] = null; // TODO
        operations[0xD5] = null; // TODO
        operations[0xD6] = null; // TODO
        operations[0xD7] = null; // TODO
        operations[0xD8] = null; // TODO
        operations[0xD9] = null; // TODO
        operations[0xDA] = null; // TODO
        operations[0xDB] = null; // TODO
        operations[0xDC] = null; // TODO
        operations[0xDD] = null; // TODO
        operations[0xDE] = null; // TODO
        operations[0xDF] = null; // TODO
        operations[0xE0] = null; // TODO
        operations[0xE1] = null; // TODO
        operations[0xE2] = null; // TODO
        operations[0xE3] = null; // TODO
        operations[0xE4] = null; // TODO
        operations[0xE5] = null; // TODO
        operations[0xE6] = null; // TODO
        operations[0xE7] = null; // TODO
        operations[0xE8] = null; // TODO
        operations[0xE9] = null; // TODO
        operations[0xEA] = null; // TODO
        operations[0xEB] = null; // TODO
        operations[0xEC] = null; // TODO
        operations[0xED] = null; // TODO
        operations[0xEE] = null; // TODO
        operations[0xEF] = null; // TODO
        operations[0xF0] = null; // TODO
        operations[0xF1] = null; // TODO
        operations[0xF2] = null; // TODO
        operations[0xF3] = null; // TODO
        operations[0xF4] = null; // TODO
        operations[0xF5] = null; // TODO
        operations[0xF6] = null; // TODO
        operations[0xF7] = null; // TODO
        operations[0xF8] = null; // TODO
        operations[0xF9] = null; // TODO
        operations[0xFA] = null; // TODO
        operations[0xFB] = null; // TODO
        operations[0xFC] = null; // TODO
        operations[0xFD] = null; // TODO
        operations[0xFE] = null; // TODO
        operations[0xFF] = null; // TODO
    }

    construct {
        registers = new Replay.DMG.Processor.Registers ();
        alu = new Replay.DMG.Processor.ALU (registers);
    }

    public int d8 () {
        // TODO: Account for cycles?
        return mmu.read_byte (registers.get_pc () + 1);
    }

    public int d16 () {
        // TODO: Account for cycles?
        return mmu.read_word (registers.get_pc () + 1);
    }

    public void tick () {
        // TODO
    }

    public void nop () {
    }

    //  public int ld (Replay.DMG.Memory.Writeable dest, Replay.DMG.Memory.Readable src) {
    //      int value = src.read ();
    //      if (false) {
    //          // TODO
    //      } else {
    //          dest.write (value);
    //      }
    //      return value;
    //  }

    // Load the value into the target register
    public void ld_immediate_to_register (Replay.DMG.Processor.Registers.Register register, int value) {
        registers.set_register_value (register, value);
    }

    // Load the contents of the source register into the memory location specified by the destination register
    public void ld_register_to_memory (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
        mmu.write_byte (registers.get_register_value (dest), registers.get_register_value (src));
    }

    // Load the contents of the memory location specified by the source register into the destination register 
    public void ld_memory_to_register (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
        registers.set_register_value (dest, mmu.read_byte (registers.get_register_value (src)));
    }

    // Load the contents of the source register into the destination register
    public void ld_register_to_register (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {

    }

    public int push () {
        return -1;
    }

    public int pop () {
        return -1;
    }

    public void add (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
        if (dest.is_16_bit_register ()) {
            alu.add2 (dest, registers.get_register_value (src));
        } else {
            alu.add (registers.get_register_value (src));
        }
    }

    public void adc (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
        if (src.is_16_bit_register ()) {
            alu.adc (mmu.read_byte (registers.get_register_value (src)));
        } else {
            alu.adc (registers.get_register_value (src));
        }
    }

    public int sub () {
        return -1;
    }

    public int sbc () {
        return -1;
    }

    public int and () {
        return -1;
    }

    public int or () {
        return -1;
    }

    public int xor () {
        return -1;
    }

    public int cp () {
        return -1;
    }

    public void inc (Replay.DMG.Processor.Registers.Register register) {
        registers.set_register_value (register, alu.inc (registers.get_register_value (register)));
    }

    public void dec (Replay.DMG.Processor.Registers.Register register) {
        registers.set_register_value (register, alu.dec (registers.get_register_value (register)));
    }

    public int swap () {
        return -1;
    }

    public int daa () {
        return -1;
    }

    public int cpl () {
        return -1;
    }

    public int ccf () {
        return -1;
    }

    public int scf () {
        return -1;
    }

    public void halt () {
        // TODO: ???
    }

    public void stop () {
        // TODO: ???
    }

    public int di () {
        return -1;
    }

    public int ei () {
        return -1;
    }

    public void rlca () {
        rlc (Replay.DMG.Processor.Registers.Register.A);
    }

    public void rlc (Replay.DMG.Processor.Registers.Register register) {
        int carry = (registers.get_register_value (register) & 0x80) >> 7;
        if (carry != 0) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        registers.set_register_value (register, registers.get_register_value (register) << 1);
        registers.set_register_value (register, registers.get_register_value (register) + carry);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    }

    public void rla () {
        rl (Replay.DMG.Processor.Registers.Register.A);
    }

    public void rl (Replay.DMG.Processor.Registers.Register register) {
        int carry = registers.get_flag (Replay.DMG.Processor.FlagRegister.Flags.C) ? 1 : 0;
        if ((registers.get_register_value (register) & 0x80) != 0) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        registers.set_register_value (register, registers.get_register_value (register) << 1);
        registers.set_register_value (register, registers.get_register_value (register) + carry);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    }

    public void rrca () {
        rrc (Replay.DMG.Processor.Registers.Register.A);
    }

    public void rrc (Replay.DMG.Processor.Registers.Register register) {
        int carry = (registers.get_register_value (register) & 0x01);
        if (carry != 0) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        registers.set_register_value (register, registers.get_register_value (register) >> 1);
        if (carry != 0) {
            registers.set_register_value (register, registers.get_register_value (register) | 0x80);
        }
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    }

    public int rra () {
        return -1;
    }

    public int rr () {
        return -1;
    }

    public int sla () {
        return -1;
    }

    public int sra () {
        return -1;
    }

    public int srl () {
        return -1;
    }

    public int bit () {
        return -1;
    }

    public new int set () {
        return -1;
    }

    public int res () {
        return -1;
    }

    public int jp () {
        return -1;
    }

    public int jr () {
        return -1;
    }

    public int call () {
        return -1;
    }

    public int rst () {
        return -1;
    }

    public int ret () {
        return -1;
    }

    public int reti () {
        return -1;
    }

    //  // 0x00
    //  private void nop () {
    //      // Do nothing
    //  }

    //  // 0x01
    //  private void ld_bc_nn (int operand) {
    //      registers.set_bc (operand);
    //  }

    //  // 0x02
    //  private void ld_bcp_a () {
    //      mmu.write_byte (registers.get_bc (), registers.get_a ());
    //  }

    //  // 0x03
    //  private void inc_bc () {
    //      registers.set_bc (registers.get_bc () + 1);
    //  }

    //  // 0x04
    //  private void inc_b () {
    //      registers.set_b (alu.inc (registers.get_b ()));
    //  }

    //  // 0x05
    //  private void dec_b () {
    //      registers.set_b (alu.dec (registers.get_b ()));
    //  }

    //  // 0x06
    //  private void ld_b_n (int operand) {
    //      registers.set_b (operand);
    //  }

    //  // 0x07
    //  private void rlca () {
    //      int carry = (registers.get_a () & 0x80) >> 7;
    //      if (carry != 0) {
    //          registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      } else {
    //          registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      }
    //      registers.set_a (registers.get_a () << 1);
    //      registers.set_a (registers.get_a () + carry);

    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    //  }

    //  // 0x08
    //  private void ld_nnp_sp (int operand) {
    //      mmu.write_byte (operand, registers.get_sp () & 0x00FF);
    //      mmu.write_byte (operand, (registers.get_sp () & 0xFF00) >> 8);
    //  }

    //  // 0x09
    //  private void add_hl_bc () {
    //      alu.add2 (Replay.DMG.Processor.Registers.Register.HL, registers.get_bc ());
    //  }

}
