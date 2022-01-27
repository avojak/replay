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
        //  operations[0x00] = new Replay.DMG.Processor.Operation ("NOP", (cpu) => { cpu.nop (); }, 1, 4);
        //  operations[0x01] = new Replay.DMG.Processor.Operation ("LD BC, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.BC, cpu.d16 ()); }, 3, 12);
        //  operations[0x02] = new Replay.DMG.Processor.Operation ("LD (BC), A", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.BC, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        //  operations[0x03] = new Replay.DMG.Processor.Operation ("INC BC", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        //  operations[0x04] = new Replay.DMG.Processor.Operation ("INC B", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x05] = new Replay.DMG.Processor.Operation ("DEC B", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x06] = new Replay.DMG.Processor.Operation ("LD B, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.B, cpu.d8 ()); }, 2, 8);
        //  operations[0x07] = new Replay.DMG.Processor.Operation ("RLCA", (cpu) => { cpu.rlca (); }, 1, 4);
        //  operations[0x08] = new Replay.DMG.Processor.Operation ("LD (a16), SP", (cpu) => { cpu.ld_register_to_immediate_16 (Replay.DMG.Processor.Registers.Register.SP); }, 3, 20);
        //  operations[0x09] = new Replay.DMG.Processor.Operation ("ADD HL, BC", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        //  operations[0x0A] = new Replay.DMG.Processor.Operation ("LD A, (BC)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        //  operations[0x0B] = new Replay.DMG.Processor.Operation ("DEC BC", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        //  operations[0x0C] = new Replay.DMG.Processor.Operation ("INC C", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x0D] = new Replay.DMG.Processor.Operation ("DEC C", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x0E] = new Replay.DMG.Processor.Operation ("LD C, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.C, cpu.d8 ()); }, 2, 8);
        //  operations[0x0F] = new Replay.DMG.Processor.Operation ("RRCA", (cpu) => { cpu.rrca (); }, 1, 4);
        //  operations[0x10] = new Replay.DMG.Processor.Operation ("STOP", (cpu) => { cpu.stop (); }, 2, 4);
        //  operations[0x11] = new Replay.DMG.Processor.Operation ("LD DE, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.DE, cpu.d16 ()); }, 3, 12);
        //  operations[0x12] = new Replay.DMG.Processor.Operation ("LD (DE), A", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.DE, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        //  operations[0x13] = new Replay.DMG.Processor.Operation ("INC DE", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        //  operations[0x14] = new Replay.DMG.Processor.Operation ("INC D", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x15] = new Replay.DMG.Processor.Operation ("DEC D", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x16] = new Replay.DMG.Processor.Operation ("LD D, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.D, cpu.d8 ()); }, 2, 8);
        //  operations[0x17] = new Replay.DMG.Processor.Operation ("RLA", (cpu) => { cpu.rla (); }, 1, 4);
        //  operations[0x18] = null; // TODO
        //  operations[0x19] = new Replay.DMG.Processor.Operation ("ADD HL, DE", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        //  operations[0x1A] = new Replay.DMG.Processor.Operation ("LD A, (DE)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        //  operations[0x1B] = new Replay.DMG.Processor.Operation ("DEC DE", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        //  operations[0x1C] = new Replay.DMG.Processor.Operation ("INC E", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x1D] = new Replay.DMG.Processor.Operation ("DEC E", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x1E] = new Replay.DMG.Processor.Operation ("LD E, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.E, cpu.d8 ()); }, 2, 8);
        //  operations[0x1F] = null; // TODO
        //  operations[0x20] = null; // TODO
        //  operations[0x21] = new Replay.DMG.Processor.Operation ("LD HL, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.HL, cpu.d16 ()); }, 3, 12);
        //  operations[0x22] = new Replay.DMG.Processor.Operation ("LD (HL+), A", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        //  operations[0x23] = new Replay.DMG.Processor.Operation ("INC HL", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x24] = new Replay.DMG.Processor.Operation ("INC H", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x25] = new Replay.DMG.Processor.Operation ("DEC H", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x26] = new Replay.DMG.Processor.Operation ("LD H, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.H, cpu.d8 ()); }, 2, 8);
        //  operations[0x27] = null; // TODO
        //  operations[0x28] = null; // TODO
        //  operations[0x29] = new Replay.DMG.Processor.Operation ("ADD HL, HL", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x2A] = new Replay.DMG.Processor.Operation ("LD A, (HL+)", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x2B] = new Replay.DMG.Processor.Operation ("DEC HL", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x2C] = new Replay.DMG.Processor.Operation ("INC L", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x2D] = new Replay.DMG.Processor.Operation ("DEC L", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x2E] = new Replay.DMG.Processor.Operation ("LD L, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.L, cpu.d8 ()); }, 2, 8);
        //  operations[0x2F] = null; // TODO
        //  operations[0x30] = null; // TODO
        //  operations[0x31] = new Replay.DMG.Processor.Operation ("LD SP, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.SP, cpu.d16 ()); }, 3, 12);
        //  operations[0x32] = new Replay.DMG.Processor.Operation ("LD (HL-), A", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        //  operations[0x33] = new Replay.DMG.Processor.Operation ("INC SP", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.SP); }, 1, 8);
        //  operations[0x34] = new Replay.DMG.Processor.Operation ("INC (HL)", (cpu) => { cpu.inc_memory (Replay.DMG.Processor.Registers.Register.HL); }, 1, 12);
        //  operations[0x35] = new Replay.DMG.Processor.Operation ("DEC (HL)", (cpu) => { cpu.dec_memory (Replay.DMG.Processor.Registers.Register.HL); }, 1, 12);
        //  operations[0x36] = new Replay.DMG.Processor.Operation ("LD (HL), d8", (cpu) => { cpu.ld_memory_to_location (Replay.DMG.Processor.Registers.Register.HL, cpu.d8 ()); }, 2, 12);
        //  operations[0x37] = null; // TODO
        //  operations[0x38] = null; // TODO
        //  operations[0x39] = new Replay.DMG.Processor.Operation ("ADD HL, SP", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.SP); }, 1, 8);
        //  operations[0x3A] = new Replay.DMG.Processor.Operation ("LD A, (HL-)", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x3B] = new Replay.DMG.Processor.Operation ("DEC SP", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.SP); }, 1, 8);
        //  operations[0x3C] = new Replay.DMG.Processor.Operation ("INC A", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x3D] = new Replay.DMG.Processor.Operation ("DEC A", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x3E] = new Replay.DMG.Processor.Operation ("LD A, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.A, cpu.d8 ()); }, 2, 8);
        //  operations[0x3F] = new Replay.DMG.Processor.Operation ("CCF", (cpu) => { cpu.ccf (); }, 1, 4);
        //  operations[0x40] = new Replay.DMG.Processor.Operation ("LD B, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x41] = new Replay.DMG.Processor.Operation ("LD B, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x42] = new Replay.DMG.Processor.Operation ("LD B, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x43] = new Replay.DMG.Processor.Operation ("LD B, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x44] = new Replay.DMG.Processor.Operation ("LD B, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x45] = new Replay.DMG.Processor.Operation ("LD B, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x46] = new Replay.DMG.Processor.Operation ("LD B, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x47] = new Replay.DMG.Processor.Operation ("LD B, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.B, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x48] = new Replay.DMG.Processor.Operation ("LD C, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x49] = new Replay.DMG.Processor.Operation ("LD C, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x4A] = new Replay.DMG.Processor.Operation ("LD C, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x4B] = new Replay.DMG.Processor.Operation ("LD C, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x4C] = new Replay.DMG.Processor.Operation ("LD C, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x4D] = new Replay.DMG.Processor.Operation ("LD C, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x4E] = new Replay.DMG.Processor.Operation ("LD C, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x4F] = new Replay.DMG.Processor.Operation ("LD C, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x50] = new Replay.DMG.Processor.Operation ("LD D, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x51] = new Replay.DMG.Processor.Operation ("LD D, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x52] = new Replay.DMG.Processor.Operation ("LD D, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x53] = new Replay.DMG.Processor.Operation ("LD D, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x54] = new Replay.DMG.Processor.Operation ("LD D, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x55] = new Replay.DMG.Processor.Operation ("LD D, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x56] = new Replay.DMG.Processor.Operation ("LD D, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x57] = new Replay.DMG.Processor.Operation ("LD D, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.D, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x58] = new Replay.DMG.Processor.Operation ("LD E, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x59] = new Replay.DMG.Processor.Operation ("LD E, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x5A] = new Replay.DMG.Processor.Operation ("LD E, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x5B] = new Replay.DMG.Processor.Operation ("LD E, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x5C] = new Replay.DMG.Processor.Operation ("LD E, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x5D] = new Replay.DMG.Processor.Operation ("LD E, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x5E] = new Replay.DMG.Processor.Operation ("LD E, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x5F] = new Replay.DMG.Processor.Operation ("LD E, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x60] = new Replay.DMG.Processor.Operation ("LD H, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x61] = new Replay.DMG.Processor.Operation ("LD H, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x62] = new Replay.DMG.Processor.Operation ("LD H, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x63] = new Replay.DMG.Processor.Operation ("LD H, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x64] = new Replay.DMG.Processor.Operation ("LD H, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x65] = new Replay.DMG.Processor.Operation ("LD H, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x66] = new Replay.DMG.Processor.Operation ("LD H, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x67] = new Replay.DMG.Processor.Operation ("LD H, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.H, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x68] = new Replay.DMG.Processor.Operation ("LD L, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x69] = new Replay.DMG.Processor.Operation ("LD L, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x6A] = new Replay.DMG.Processor.Operation ("LD L, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x6B] = new Replay.DMG.Processor.Operation ("LD L, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x6C] = new Replay.DMG.Processor.Operation ("LD L, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x6D] = new Replay.DMG.Processor.Operation ("LD L, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x6E] = new Replay.DMG.Processor.Operation ("LD L, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x6F] = new Replay.DMG.Processor.Operation ("LD L, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x70] = new Replay.DMG.Processor.Operation ("LD (HL), B", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.B); }, 1, 8);
        //  operations[0x71] = new Replay.DMG.Processor.Operation ("LD (HL), C", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.C); }, 1, 8);
        //  operations[0x72] = new Replay.DMG.Processor.Operation ("LD (HL), D", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.D); }, 1, 8);
        //  operations[0x73] = new Replay.DMG.Processor.Operation ("LD (HL), E", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.E); }, 1, 8);
        //  operations[0x74] = new Replay.DMG.Processor.Operation ("LD (HL), H", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.H); }, 1, 8);
        //  operations[0x75] = new Replay.DMG.Processor.Operation ("LD (HL), L", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.L); }, 1, 8);
        //  operations[0x76] = new Replay.DMG.Processor.Operation ("HALT", (cpu) => { cpu.halt (); }, 1, 4);
        //  operations[0x77] = new Replay.DMG.Processor.Operation ("LD (HL), A", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        //  operations[0x78] = new Replay.DMG.Processor.Operation ("LD A, B", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x79] = new Replay.DMG.Processor.Operation ("LD A, C", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x7A] = new Replay.DMG.Processor.Operation ("LD A, D", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x7B] = new Replay.DMG.Processor.Operation ("LD A, E", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x7C] = new Replay.DMG.Processor.Operation ("LD A, H", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x7D] = new Replay.DMG.Processor.Operation ("LD A, L", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x7E] = new Replay.DMG.Processor.Operation ("LD A, (HL)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        //  operations[0x7F] = new Replay.DMG.Processor.Operation ("LD A, A", (cpu) => { cpu.ld_register_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x80] = new Replay.DMG.Processor.Operation ("ADD A, B", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x81] = new Replay.DMG.Processor.Operation ("ADD A, C", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x82] = new Replay.DMG.Processor.Operation ("ADD A, D", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x83] = new Replay.DMG.Processor.Operation ("ADD A, E", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x84] = new Replay.DMG.Processor.Operation ("ADD A, H", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x85] = new Replay.DMG.Processor.Operation ("ADD A, L", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x86] = null; // TODO
        //  operations[0x87] = new Replay.DMG.Processor.Operation ("ADD A, A", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x88] = new Replay.DMG.Processor.Operation ("ADC A, B", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x89] = new Replay.DMG.Processor.Operation ("ADC A, C", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x8A] = new Replay.DMG.Processor.Operation ("ADC A, D", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x8B] = new Replay.DMG.Processor.Operation ("ADC A, E", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x8C] = new Replay.DMG.Processor.Operation ("ADC A, H", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x8D] = new Replay.DMG.Processor.Operation ("ADC A, L", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x8E] = null; // TODO
        //  operations[0x8F] = new Replay.DMG.Processor.Operation ("ADC A, A", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x90] = new Replay.DMG.Processor.Operation ("SUB B", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x91] = new Replay.DMG.Processor.Operation ("SUB C", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x92] = new Replay.DMG.Processor.Operation ("SUB D", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x93] = new Replay.DMG.Processor.Operation ("SUB E", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x94] = new Replay.DMG.Processor.Operation ("SUB H", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x95] = new Replay.DMG.Processor.Operation ("SUB L", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x96] = null; // TODO
        //  operations[0x97] = new Replay.DMG.Processor.Operation ("SUB A", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0x98] = new Replay.DMG.Processor.Operation ("SBC B", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0x99] = new Replay.DMG.Processor.Operation ("SBC C", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0x9A] = new Replay.DMG.Processor.Operation ("SBC D", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0x9B] = new Replay.DMG.Processor.Operation ("SBC E", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0x9C] = new Replay.DMG.Processor.Operation ("SBC H", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0x9D] = new Replay.DMG.Processor.Operation ("SBC L", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0x9E] = null; // TODO
        //  operations[0x9F] = new Replay.DMG.Processor.Operation ("SBC A", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0xA0] = new Replay.DMG.Processor.Operation ("AND B", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0xA1] = new Replay.DMG.Processor.Operation ("AND C", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0xA2] = new Replay.DMG.Processor.Operation ("AND D", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0xA3] = new Replay.DMG.Processor.Operation ("AND E", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0xA4] = new Replay.DMG.Processor.Operation ("AND H", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0xA5] = new Replay.DMG.Processor.Operation ("AND L", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0xA6] = null; // TODO
        //  operations[0xA7] = new Replay.DMG.Processor.Operation ("AND A", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0xA8] = new Replay.DMG.Processor.Operation ("XOR B", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0xA9] = new Replay.DMG.Processor.Operation ("XOR C", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0xAA] = new Replay.DMG.Processor.Operation ("XOR D", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0xAB] = new Replay.DMG.Processor.Operation ("XOR E", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0xAC] = new Replay.DMG.Processor.Operation ("XOR H", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0xAD] = new Replay.DMG.Processor.Operation ("XOR L", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0xAE] = null; // TODO
        //  operations[0xAF] = new Replay.DMG.Processor.Operation ("XOR A", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0xB0] = new Replay.DMG.Processor.Operation ("OR B", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0xB1] = new Replay.DMG.Processor.Operation ("OR C", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0xB2] = new Replay.DMG.Processor.Operation ("OR D", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0xB3] = new Replay.DMG.Processor.Operation ("OR E", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0xB4] = new Replay.DMG.Processor.Operation ("OR H", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0xB5] = new Replay.DMG.Processor.Operation ("OR L", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0xB6] = null; // TODO
        //  operations[0xB7] = new Replay.DMG.Processor.Operation ("OR A", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0xB8] = new Replay.DMG.Processor.Operation ("CP B", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        //  operations[0xB9] = new Replay.DMG.Processor.Operation ("CP C", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        //  operations[0xBA] = new Replay.DMG.Processor.Operation ("CP D", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        //  operations[0xBB] = new Replay.DMG.Processor.Operation ("CP E", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        //  operations[0xBC] = new Replay.DMG.Processor.Operation ("CP H", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        //  operations[0xBD] = new Replay.DMG.Processor.Operation ("CP L", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        //  operations[0xBE] = null; // TODO
        //  operations[0xBF] = new Replay.DMG.Processor.Operation ("CP A", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        //  operations[0xC0] = null; // TODO
        //  operations[0xC1] = new Replay.DMG.Processor.Operation ("POP BC", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.BC); }, 1, 12);
        //  operations[0xC2] = null; // TODO
        //  operations[0xC3] = null; // TODO
        //  operations[0xC4] = null; // TODO
        //  operations[0xC5] = new Replay.DMG.Processor.Operation ("PUSH BC", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.BC); }, 1, 16);
        //  operations[0xC6] = new Replay.DMG.Processor.Operation ("ADD A, d8", (cpu) => { cpu.add_immediate_to_register (Replay.DMG.Processor.Registers.Register.A, cpu.d8 ()); }, 2, 8);
        //  operations[0xC7] = null; // TODO
        //  operations[0xC8] = null; // TODO
        //  operations[0xC9] = null; // TODO
        //  operations[0xCA] = null; // TODO
        //  operations[0xCB] = null; // TODO
        //  operations[0xCC] = null; // TODO
        //  operations[0xCD] = null; // TODO
        //  operations[0xCE] = new Replay.DMG.Processor.Operation ("ADC A, d8", (cpu) => { cpu.adc_immediate_to_register (Replay.DMG.Processor.Registers.Register.A, cpu.d8 ()); }, 2, 8);
        //  operations[0xCF] = null; // TODO
        //  operations[0xD0] = null; // TODO
        //  operations[0xD1] = new Replay.DMG.Processor.Operation ("POP DE", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.DE); }, 1, 12);
        //  operations[0xD2] = null; // TODO
        //  operations[0xD3] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xD4] = null; // TODO
        //  operations[0xD5] = new Replay.DMG.Processor.Operation ("PUSH DE", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.DE); }, 1, 16);
        //  operations[0xD6] = null; // TODO
        //  operations[0xD7] = null; // TODO
        //  operations[0xD8] = null; // TODO
        //  operations[0xD9] = null; // TODO
        //  operations[0xDA] = null; // TODO
        //  operations[0xDB] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xDC] = null; // TODO
        //  operations[0xDD] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xDE] = null; // TODO
        //  operations[0xDF] = null; // TODO
        //  operations[0xE0] = null; // TODO
        //  operations[0xE1] = new Replay.DMG.Processor.Operation ("POP HL", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.HL); }, 1, 12);
        //  operations[0xE2] = null; // TODO
        //  operations[0xE3] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xE4] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xE5] = new Replay.DMG.Processor.Operation ("PUSH HL", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.HL); }, 1, 16);
        //  operations[0xE6] = null; // TODO
        //  operations[0xE7] = null; // TODO
        //  operations[0xE8] = null; // TODO
        //  operations[0xE9] = null; // TODO
        //  operations[0xEA] = null; // TODO
        //  operations[0xEB] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xEC] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xED] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xEE] = null; // TODO
        //  operations[0xEF] = null; // TODO
        //  operations[0xF0] = null; // TODO
        //  operations[0xF1] = new Replay.DMG.Processor.Operation ("POP AF", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.AF); }, 1, 12);
        //  operations[0xF2] = null; // TODO
        //  operations[0xF3] = null; // TODO
        //  operations[0xF4] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xF5] = new Replay.DMG.Processor.Operation ("PUSH AF", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.AF); }, 1, 16);
        //  operations[0xF6] = null; // TODO
        //  operations[0xF7] = null; // TODO
        //  operations[0xF8] = null; // TODO
        //  operations[0xF9] = null; // TODO
        //  operations[0xFA] = null; // TODO
        //  operations[0xFB] = null; // TODO
        //  operations[0xFC] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xFD] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        //  operations[0xFE] = null; // TODO
        //  operations[0xFF] = null; // TODO

        operations[0x00] = new Replay.DMG.Processor.Operation ("NOP", (cpu) => { cpu.nop (); });
        operations[0x01] = new Replay.DMG.Processor.Operation ("LD BC, d16", (cpu) => { cpu.ld_bc (); });
        operations[0x02] = new Replay.DMG.Processor.Operation ("LD (BC), A", (cpu) => { cpu.ld_bc_loc_a (); });
        operations[0x03] = new Replay.DMG.Processor.Operation ("INC BC", (cpu) => { cpu.inc_bc (); });
        operations[0x04] = new Replay.DMG.Processor.Operation ("INC B", (cpu) => { cpu.inc_b (); });
        operations[0x05] = new Replay.DMG.Processor.Operation ("DEC B", (cpu) => { cpu.dec_b (); });
        operations[0x06] = new Replay.DMG.Processor.Operation ("LD B, d8", (cpu) => { cpu.ld_b (); });
        operations[0x07] = new Replay.DMG.Processor.Operation ("RLCA", (cpu) => { cpu.rlca (); });
        operations[0x08] = new Replay.DMG.Processor.Operation ("LD (a16) SP", (cpu) => { cpu.ld_a16_loc_sp (); });
        operations[0x09] = new Replay.DMG.Processor.Operation ("ADD HL, BC", (cpu) => { cpu.add_hl_bc (); });
        operations[0x0A] = null; // TODO
        operations[0x0B] = null; // TODO
        operations[0x0C] = new Replay.DMG.Processor.Operation ("INC C", (cpu) => { cpu.inc_c (); });
        operations[0x0D] = new Replay.DMG.Processor.Operation ("DEC C", (cpu) => { cpu.dec_c (); });
        operations[0x0E] = new Replay.DMG.Processor.Operation ("LD C, d8", (cpu) => { cpu.ld_c (); });
        operations[0x0F] = null; // TODO
        operations[0x10] = null; // TODO
        operations[0x11] = new Replay.DMG.Processor.Operation ("LD DE, d16", (cpu) => { cpu.ld_de (); });
        operations[0x12] = new Replay.DMG.Processor.Operation ("LD (DE), A", (cpu) => { cpu.ld_de_loc_a (); });
        operations[0x13] = new Replay.DMG.Processor.Operation ("INC DE", (cpu) => { cpu.inc_de (); });
        operations[0x14] = new Replay.DMG.Processor.Operation ("INC D", (cpu) => { cpu.inc_d (); });
        operations[0x15] = new Replay.DMG.Processor.Operation ("DEC D", (cpu) => { cpu.dec_d (); });
        operations[0x16] = new Replay.DMG.Processor.Operation ("LD D, d8", (cpu) => { cpu.ld_d (); });
        operations[0x17] = null; // TODO
        operations[0x18] = null; // TODO
        operations[0x19] = new Replay.DMG.Processor.Operation ("ADD HL, DE", (cpu) => { cpu.add_hl_de (); });
        operations[0x1A] = new Replay.DMG.Processor.Operation ("LD A, (DE)", (cpu) => { cpu.ld_a_de_loc (); });
        operations[0x1B] = new Replay.DMG.Processor.Operation ("DEC DE", (cpu) => { cpu.dec_de (); });
        operations[0x1C] = new Replay.DMG.Processor.Operation ("INC E", (cpu) => { cpu.inc_e (); });
        operations[0x1D] = new Replay.DMG.Processor.Operation ("DEC E", (cpu) => { cpu.dec_e (); });
        operations[0x1E] = new Replay.DMG.Processor.Operation ("LD E, d8", (cpu) => { cpu.ld_e (); });
        operations[0x1F] = null; // TODO
        operations[0x20] = null; // TODO
        operations[0x21] = new Replay.DMG.Processor.Operation ("LD HL, d16", (cpu) => { cpu.ld_hl (); });
        operations[0x22] = new Replay.DMG.Processor.Operation ("LD (HL+), A", (cpu) => { cpu.ld_hl_plus_a (); });
        operations[0x23] = new Replay.DMG.Processor.Operation ("INC HL", (cpu) => { cpu.inc_hl (); });
        operations[0x24] = new Replay.DMG.Processor.Operation ("INC H", (cpu) => { cpu.inc_h (); });
        operations[0x25] = new Replay.DMG.Processor.Operation ("DEC H", (cpu) => { cpu.dec_h (); });
        operations[0x26] = new Replay.DMG.Processor.Operation ("LD H, d8", (cpu) => { cpu.ld_h (); });
        operations[0x27] = null; // TODO
        operations[0x28] = null; // TODO
        operations[0x29] = new Replay.DMG.Processor.Operation ("ADD HL, HL", (cpu) => { cpu.add_hl_hl (); });
        operations[0x2A] = new Replay.DMG.Processor.Operation ("LD A, (HL+)", (cpu) => { cpu.ld_a_hl_plus (); });
        operations[0x2B] = new Replay.DMG.Processor.Operation ("DEC HL", (cpu) => { cpu.dec_hl (); });
        operations[0x2C] = new Replay.DMG.Processor.Operation ("INC L", (cpu) => { cpu.inc_l (); });
        operations[0x2D] = new Replay.DMG.Processor.Operation ("DEC L", (cpu) => { cpu.dec_l (); });
        operations[0x2E] = new Replay.DMG.Processor.Operation ("LD L, d8", (cpu) => { cpu.ld_l (); });
        operations[0x2F] = new Replay.DMG.Processor.Operation ("CPL", (cpu) => { cpu.cpl (); });
        operations[0x30] = null; // TODO
        operations[0x31] = null; // TODO
        operations[0x32] = new Replay.DMG.Processor.Operation ("LD (HL-), A", (cpu) => { cpu.ld_hl_minus_a (); });
        operations[0x33] = null; // TODO
        operations[0x34] = new Replay.DMG.Processor.Operation ("INC (HL)", (cpu) => { cpu.inc_hl_loc (); });
        operations[0x35] = new Replay.DMG.Processor.Operation ("DEC (HL)", (cpu) => { cpu.dec_hl_loc (); });
        operations[0x36] = new Replay.DMG.Processor.Operation ("LD (HL), d8", (cpu) => { cpu.ld_hl_loc_d8 (); });
        operations[0x37] = null; // TODO
        operations[0x38] = null; // TODO
        operations[0x39] = new Replay.DMG.Processor.Operation ("ADD HL, SP", (cpu) => { cpu.add_hl_sp (); });
        operations[0x3A] = new Replay.DMG.Processor.Operation ("LD A, (HL-)", (cpu) => { cpu.ld_a_hl_minus (); });
        operations[0x3B] = null; // TODO
        operations[0x3C] = new Replay.DMG.Processor.Operation ("INC A", (cpu) => { cpu.inc_a (); });
        operations[0x3D] = new Replay.DMG.Processor.Operation ("DEC A", (cpu) => { cpu.dec_a (); });
        operations[0x3E] = new Replay.DMG.Processor.Operation ("LD A, d8", (cpu) => { cpu.ld_a (); });
        operations[0x3F] = new Replay.DMG.Processor.Operation ("CCF", (cpu) => { cpu.ccf (); });
        operations[0x40] = new Replay.DMG.Processor.Operation ("LD B, B", (cpu) => { cpu.ld_b_b (); });
        operations[0x41] = new Replay.DMG.Processor.Operation ("LD B, C", (cpu) => { cpu.ld_b_c (); });
        operations[0x42] = new Replay.DMG.Processor.Operation ("LD B, D", (cpu) => { cpu.ld_b_d (); });
        operations[0x43] = new Replay.DMG.Processor.Operation ("LD B, E", (cpu) => { cpu.ld_b_e (); });
        operations[0x44] = new Replay.DMG.Processor.Operation ("LD B, H", (cpu) => { cpu.ld_b_h (); });
        operations[0x45] = new Replay.DMG.Processor.Operation ("LD B, L", (cpu) => { cpu.ld_b_l (); });
        operations[0x46] = new Replay.DMG.Processor.Operation ("LD B, (HL)", (cpu) => { cpu.ld_b_hl_loc (); });
        operations[0x47] = new Replay.DMG.Processor.Operation ("LD B, A", (cpu) => { cpu.ld_b_a (); });
        operations[0x48] = new Replay.DMG.Processor.Operation ("LD C, B", (cpu) => { cpu.ld_c_b (); });
        operations[0x49] = new Replay.DMG.Processor.Operation ("LD C, C", (cpu) => { cpu.ld_c_c (); });
        operations[0x4A] = new Replay.DMG.Processor.Operation ("LD C, D", (cpu) => { cpu.ld_c_d (); });
        operations[0x4B] = new Replay.DMG.Processor.Operation ("LD C, E", (cpu) => { cpu.ld_c_e (); });
        operations[0x4C] = new Replay.DMG.Processor.Operation ("LD C, H", (cpu) => { cpu.ld_c_h (); });
        operations[0x4D] = new Replay.DMG.Processor.Operation ("LD C, L", (cpu) => { cpu.ld_c_l (); });
        operations[0x4E] = new Replay.DMG.Processor.Operation ("LD C, (HL)", (cpu) => { cpu.ld_c_hl_loc (); });
        operations[0x4F] = new Replay.DMG.Processor.Operation ("LD C, A", (cpu) => { cpu.ld_c_a (); });
        operations[0x50] = new Replay.DMG.Processor.Operation ("LD D, B", (cpu) => { cpu.ld_d_b (); });
        operations[0x51] = new Replay.DMG.Processor.Operation ("LD D, C", (cpu) => { cpu.ld_d_c (); });
        operations[0x52] = new Replay.DMG.Processor.Operation ("LD D, D", (cpu) => { cpu.ld_d_d (); });
        operations[0x53] = new Replay.DMG.Processor.Operation ("LD D, E", (cpu) => { cpu.ld_d_e (); });
        operations[0x54] = new Replay.DMG.Processor.Operation ("LD D, H", (cpu) => { cpu.ld_d_h (); });
        operations[0x55] = new Replay.DMG.Processor.Operation ("LD D, L", (cpu) => { cpu.ld_d_l (); });
        operations[0x56] = new Replay.DMG.Processor.Operation ("LD D, (HL)", (cpu) => { cpu.ld_d_hl_loc (); });
        operations[0x57] = new Replay.DMG.Processor.Operation ("LD D, A", (cpu) => { cpu.ld_d_a (); });
        operations[0x58] = new Replay.DMG.Processor.Operation ("LD E, B", (cpu) => { cpu.ld_e_b (); });
        operations[0x59] = new Replay.DMG.Processor.Operation ("LD E, C", (cpu) => { cpu.ld_e_c (); });
        operations[0x5A] = new Replay.DMG.Processor.Operation ("LD E, D", (cpu) => { cpu.ld_e_d (); });
        operations[0x5B] = new Replay.DMG.Processor.Operation ("LD E, E", (cpu) => { cpu.ld_e_e (); });
        operations[0x5C] = new Replay.DMG.Processor.Operation ("LD E, H", (cpu) => { cpu.ld_e_h (); });
        operations[0x5D] = new Replay.DMG.Processor.Operation ("LD E, L", (cpu) => { cpu.ld_e_l (); });
        operations[0x5E] = new Replay.DMG.Processor.Operation ("LD E, (HL)", (cpu) => { cpu.ld_e_hl_loc (); });
        operations[0x5F] = new Replay.DMG.Processor.Operation ("LD E, A", (cpu) => { cpu.ld_e_a (); });
        operations[0x60] = new Replay.DMG.Processor.Operation ("LD H, B", (cpu) => { cpu.ld_h_b (); });
        operations[0x61] = new Replay.DMG.Processor.Operation ("LD H, C", (cpu) => { cpu.ld_h_c (); });
        operations[0x62] = new Replay.DMG.Processor.Operation ("LD H, D", (cpu) => { cpu.ld_h_d (); });
        operations[0x63] = new Replay.DMG.Processor.Operation ("LD H, E", (cpu) => { cpu.ld_h_e (); });
        operations[0x64] = new Replay.DMG.Processor.Operation ("LD H, H", (cpu) => { cpu.ld_h_h (); });
        operations[0x65] = new Replay.DMG.Processor.Operation ("LD H, L", (cpu) => { cpu.ld_h_l (); });
        operations[0x66] = new Replay.DMG.Processor.Operation ("LD H, (HL)", (cpu) => { cpu.ld_h_hl_loc (); });
        operations[0x67] = new Replay.DMG.Processor.Operation ("LD H, A", (cpu) => { cpu.ld_h_a (); });
        operations[0x68] = new Replay.DMG.Processor.Operation ("LD L, B", (cpu) => { cpu.ld_l_b (); });
        operations[0x69] = new Replay.DMG.Processor.Operation ("LD L, C", (cpu) => { cpu.ld_l_c (); });
        operations[0x6A] = new Replay.DMG.Processor.Operation ("LD L, D", (cpu) => { cpu.ld_l_d (); });
        operations[0x6B] = new Replay.DMG.Processor.Operation ("LD L, E", (cpu) => { cpu.ld_l_e (); });
        operations[0x6C] = new Replay.DMG.Processor.Operation ("LD L, H", (cpu) => { cpu.ld_l_h (); });
        operations[0x6D] = new Replay.DMG.Processor.Operation ("LD L, L", (cpu) => { cpu.ld_l_l (); });
        operations[0x6E] = new Replay.DMG.Processor.Operation ("LD L, (HL)", (cpu) => { cpu.ld_l_hl_loc (); });
        operations[0x6F] = new Replay.DMG.Processor.Operation ("LD L, A", (cpu) => { cpu.ld_l_a (); });
        operations[0x70] = new Replay.DMG.Processor.Operation ("LD (HL), B", (cpu) => { cpu.ld_hl_loc_b (); });
        operations[0x71] = new Replay.DMG.Processor.Operation ("LD (HL), C", (cpu) => { cpu.ld_hl_loc_c (); });
        operations[0x72] = new Replay.DMG.Processor.Operation ("LD (HL), D", (cpu) => { cpu.ld_hl_loc_d (); });
        operations[0x73] = new Replay.DMG.Processor.Operation ("LD (HL), E", (cpu) => { cpu.ld_hl_loc_e (); });
        operations[0x74] = new Replay.DMG.Processor.Operation ("LD (HL), H", (cpu) => { cpu.ld_hl_loc_h (); });
        operations[0x75] = new Replay.DMG.Processor.Operation ("LD (HL), L", (cpu) => { cpu.ld_hl_loc_l (); });
        operations[0x76] = new Replay.DMG.Processor.Operation ("HALT", (cpu) => { cpu.halt (); });
        operations[0x77] = new Replay.DMG.Processor.Operation ("LD (HL), A", (cpu) => { cpu.ld_hl_loc_a (); });
        operations[0x78] = new Replay.DMG.Processor.Operation ("LD A, B", (cpu) => { cpu.ld_a_b (); });
        operations[0x79] = new Replay.DMG.Processor.Operation ("LD A, C", (cpu) => { cpu.ld_a_c (); });
        operations[0x7A] = new Replay.DMG.Processor.Operation ("LD A, D", (cpu) => { cpu.ld_a_d (); });
        operations[0x7B] = new Replay.DMG.Processor.Operation ("LD A, E", (cpu) => { cpu.ld_a_e (); });
        operations[0x7C] = new Replay.DMG.Processor.Operation ("LD A, H", (cpu) => { cpu.ld_a_h (); });
        operations[0x7D] = new Replay.DMG.Processor.Operation ("LD A, L", (cpu) => { cpu.ld_a_l (); });
        operations[0x7E] = new Replay.DMG.Processor.Operation ("LD A, (HL)", (cpu) => { cpu.ld_a_hl_loc (); });
        operations[0x7F] = new Replay.DMG.Processor.Operation ("LD A, A", (cpu) => { cpu.ld_a_a (); });
        operations[0x80] = new Replay.DMG.Processor.Operation ("ADD A, B", (cpu) => { cpu.ld_a_b (); });
        operations[0x81] = new Replay.DMG.Processor.Operation ("ADD A, C", (cpu) => { cpu.ld_a_c (); });
        operations[0x82] = new Replay.DMG.Processor.Operation ("ADD A, D", (cpu) => { cpu.ld_a_d (); });
        operations[0x83] = new Replay.DMG.Processor.Operation ("ADD A, E", (cpu) => { cpu.ld_a_e (); });
        operations[0x84] = new Replay.DMG.Processor.Operation ("ADD A, H", (cpu) => { cpu.ld_a_h (); });
        operations[0x85] = new Replay.DMG.Processor.Operation ("ADD A, L", (cpu) => { cpu.ld_a_l (); });
        operations[0x86] = null; // TODO
        operations[0x87] = new Replay.DMG.Processor.Operation ("ADD A, A", (cpu) => { cpu.add_a_a (); });
        operations[0x88] = new Replay.DMG.Processor.Operation ("ADC A, B", (cpu) => { cpu.adc_a_b (); });
        operations[0x89] = new Replay.DMG.Processor.Operation ("ADC A, C", (cpu) => { cpu.adc_a_c (); });
        operations[0x8A] = new Replay.DMG.Processor.Operation ("ADC A, D", (cpu) => { cpu.adc_a_d (); });
        operations[0x8B] = new Replay.DMG.Processor.Operation ("ADC A, E", (cpu) => { cpu.adc_a_e (); });
        operations[0x8C] = new Replay.DMG.Processor.Operation ("ADC A, H", (cpu) => { cpu.adc_a_h (); });
        operations[0x8D] = new Replay.DMG.Processor.Operation ("ADC A, L", (cpu) => { cpu.adc_a_l (); });
        operations[0x8E] = new Replay.DMG.Processor.Operation ("ADC A, (HL)", (cpu) => { cpu.adc_a_hl_loc (); });
        operations[0x8F] = new Replay.DMG.Processor.Operation ("ADC A, A", (cpu) => { cpu.adc_a_a (); });
        operations[0x90] = new Replay.DMG.Processor.Operation ("SUB B", (cpu) => { cpu.sub_b (); });
        operations[0x91] = new Replay.DMG.Processor.Operation ("SUB C", (cpu) => { cpu.sub_c (); });
        operations[0x92] = new Replay.DMG.Processor.Operation ("SUB D", (cpu) => { cpu.sub_d (); });
        operations[0x93] = new Replay.DMG.Processor.Operation ("SUB E", (cpu) => { cpu.sub_e (); });
        operations[0x94] = new Replay.DMG.Processor.Operation ("SUB H", (cpu) => { cpu.sub_h (); });
        operations[0x95] = new Replay.DMG.Processor.Operation ("SUB L", (cpu) => { cpu.sub_l (); });
        operations[0x96] = new Replay.DMG.Processor.Operation ("SUB (HL)", (cpu) => { cpu.sub_hl_loc (); });
        operations[0x97] = new Replay.DMG.Processor.Operation ("SUB A", (cpu) => { cpu.sub_a (); });
        operations[0x98] = new Replay.DMG.Processor.Operation ("SBC A, B", (cpu) => { cpu.sbc_a_b (); });
        operations[0x99] = new Replay.DMG.Processor.Operation ("SBC A, C", (cpu) => { cpu.sbc_a_c (); });
        operations[0x9A] = new Replay.DMG.Processor.Operation ("SBC A, D", (cpu) => { cpu.sbc_a_d (); });
        operations[0x9B] = new Replay.DMG.Processor.Operation ("SBC A, E", (cpu) => { cpu.sbc_a_e (); });
        operations[0x9C] = new Replay.DMG.Processor.Operation ("SBC A, H", (cpu) => { cpu.sbc_a_h (); });
        operations[0x9D] = new Replay.DMG.Processor.Operation ("SBC A, L", (cpu) => { cpu.sbc_a_l (); });
        operations[0x9E] = null; // TODO new Replay.DMG.Processor.Operation ("SBC A, (HL)", (cpu) => { cpu.sbc_a_hl_loc (); });
        operations[0x9F] = new Replay.DMG.Processor.Operation ("SBC A, A", (cpu) => { cpu.sbc_a_a (); });
        operations[0xA0] = new Replay.DMG.Processor.Operation ("AND B", (cpu) => { cpu.and_b (); });
        operations[0xA1] = new Replay.DMG.Processor.Operation ("AND C", (cpu) => { cpu.and_c (); });
        operations[0xA2] = new Replay.DMG.Processor.Operation ("AND D", (cpu) => { cpu.and_d (); });
        operations[0xA3] = new Replay.DMG.Processor.Operation ("AND E", (cpu) => { cpu.and_e (); });
        operations[0xA4] = new Replay.DMG.Processor.Operation ("AND H", (cpu) => { cpu.and_h (); });
        operations[0xA5] = new Replay.DMG.Processor.Operation ("AND L", (cpu) => { cpu.and_l (); });
        operations[0xA6] = null; // TODO
        operations[0xA7] = new Replay.DMG.Processor.Operation ("AND A", (cpu) => { cpu.and_a (); });
        operations[0xA8] = new Replay.DMG.Processor.Operation ("XOR B", (cpu) => { cpu.xor_b (); });
        operations[0xA9] = new Replay.DMG.Processor.Operation ("XOR C", (cpu) => { cpu.xor_c (); });
        operations[0xAA] = new Replay.DMG.Processor.Operation ("XOR D", (cpu) => { cpu.xor_d (); });
        operations[0xAB] = new Replay.DMG.Processor.Operation ("XOR E", (cpu) => { cpu.xor_e (); });
        operations[0xAC] = new Replay.DMG.Processor.Operation ("XOR H", (cpu) => { cpu.xor_h (); });
        operations[0xAD] = new Replay.DMG.Processor.Operation ("XOR L", (cpu) => { cpu.xor_l (); });
        operations[0xAE] = new Replay.DMG.Processor.Operation ("XOR (HL)", (cpu) => { cpu.xor_hl_loc (); });
        operations[0xAF] = new Replay.DMG.Processor.Operation ("XOR A", (cpu) => { cpu.xor_a (); });
        operations[0xB0] = new Replay.DMG.Processor.Operation ("OR B", (cpu) => { cpu.or_b (); });
        operations[0xB1] = new Replay.DMG.Processor.Operation ("OR C", (cpu) => { cpu.or_c (); });
        operations[0xB2] = new Replay.DMG.Processor.Operation ("OR D", (cpu) => { cpu.or_d (); });
        operations[0xB3] = new Replay.DMG.Processor.Operation ("OR E", (cpu) => { cpu.or_e (); });
        operations[0xB4] = new Replay.DMG.Processor.Operation ("OR H", (cpu) => { cpu.or_h (); });
        operations[0xB5] = new Replay.DMG.Processor.Operation ("OR L", (cpu) => { cpu.or_l (); });
        operations[0xB6] = new Replay.DMG.Processor.Operation ("OR (HL)", (cpu) => { cpu.or_hl_loc (); });
        operations[0xB7] = new Replay.DMG.Processor.Operation ("OR A", (cpu) => { cpu.or_a (); });
        operations[0xB8] = new Replay.DMG.Processor.Operation ("CP B", (cpu) => { cpu.cp_b (); });
        operations[0xB9] = new Replay.DMG.Processor.Operation ("CP C", (cpu) => { cpu.cp_c (); });
        operations[0xBA] = new Replay.DMG.Processor.Operation ("CP D", (cpu) => { cpu.cp_d (); });
        operations[0xBB] = new Replay.DMG.Processor.Operation ("CP E", (cpu) => { cpu.cp_e (); });
        operations[0xBC] = new Replay.DMG.Processor.Operation ("CP H", (cpu) => { cpu.cp_h (); });
        operations[0xBD] = new Replay.DMG.Processor.Operation ("CP L", (cpu) => { cpu.cp_l (); });
        operations[0xBE] = new Replay.DMG.Processor.Operation ("CP (HL)", (cpu) => { cpu.cp_hl_loc (); });
        operations[0xBF] = new Replay.DMG.Processor.Operation ("CP A", (cpu) => { cpu.cp_a (); });
        operations[0xC0] = null; // TODO
        operations[0xC1] = null; // TODO
        operations[0xC2] = null; // TODO
        operations[0xC3] = null; // TODO
        operations[0xC4] = null; // TODO
        operations[0xC5] = null; // TODO
        operations[0xC6] = null; // TODO
        operations[0xC7] = new Replay.DMG.Processor.Operation ("RST 0", (cpu) => { cpu.rst_0 (); });
        operations[0xC8] = null; // TODO
        operations[0xC9] = null; // TODO
        operations[0xCA] = null; // TODO
        operations[0xCB] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xCC] = null; // TODO
        operations[0xCD] = null; // TODO
        operations[0xCE] = new Replay.DMG.Processor.Operation ("ADC A, d8", (cpu) => { cpu.adc_a_d8 (); });
        operations[0xCF] = new Replay.DMG.Processor.Operation ("RST 1", (cpu) => { cpu.rst_1 (); });
        operations[0xD0] = null; // TODO
        operations[0xD1] = null; // TODO
        operations[0xD2] = null; // TODO
        operations[0xD3] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xD4] = null; // TODO
        operations[0xD5] = null; // TODO
        operations[0xD6] = new Replay.DMG.Processor.Operation ("SUB d8", (cpu) => { cpu.sub_d8 (); });
        operations[0xD7] = new Replay.DMG.Processor.Operation ("RST 2", (cpu) => { cpu.rst_2 (); });
        operations[0xD8] = null; // TODO
        operations[0xD9] = null; // TODO
        operations[0xDA] = null; // TODO
        operations[0xDB] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xDC] = null; // TODO
        operations[0xDD] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xDE] = null; // TODO
        operations[0xDF] = new Replay.DMG.Processor.Operation ("RST 3", (cpu) => { cpu.rst_3 (); });
        operations[0xE0] = null; // TODO
        operations[0xE1] = null; // TODO
        operations[0xE2] = new Replay.DMG.Processor.Operation ("LD (C), A", (cpu) => { cpu.ld_c_loc_a (); });
        operations[0xE3] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xE4] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xE5] = null; // TODO
        operations[0xE6] = new Replay.DMG.Processor.Operation ("AND d8", (cpu) => { cpu.and_d8 (); });
        operations[0xE7] = new Replay.DMG.Processor.Operation ("RST 4", (cpu) => { cpu.rst_4 (); });
        operations[0xE8] = null; // TODO
        operations[0xE9] = null; // TODO
        operations[0xEA] = null; // TODO
        operations[0xEB] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xEC] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xED] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xEE] = new Replay.DMG.Processor.Operation ("XOR d8", (cpu) => { cpu.xor_d8 (); });
        operations[0xEF] = new Replay.DMG.Processor.Operation ("RST 5", (cpu) => { cpu.rst_5 (); });
        operations[0xF0] = null; // TODO
        operations[0xF1] = null; // TODO
        operations[0xF2] = null; // TODO
        operations[0xF3] = new Replay.DMG.Processor.Operation ("DI", (cpu) => { cpu.di (); });
        operations[0xF4] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xF5] = null; // TODO
        operations[0xF6] = new Replay.DMG.Processor.Operation ("OR d8", (cpu) => { cpu.or_d8 (); });
        operations[0xF7] = new Replay.DMG.Processor.Operation ("RST 6", (cpu) => { cpu.rst_6 (); });
        operations[0xF8] = null; // TODO
        operations[0xF9] = null; // TODO
        operations[0xFA] = null; // TODO
        operations[0xFB] = new Replay.DMG.Processor.Operation ("EI", (cpu) => { cpu.ei (); });
        operations[0xFC] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xFD] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); });
        operations[0xFE] = null; // TODO
        operations[0xFF] = new Replay.DMG.Processor.Operation ("RST 7", (cpu) => { cpu.rst_7 (); });
    }

    construct {
        registers = new Replay.DMG.Processor.Registers ();
        alu = new Replay.DMG.Processor.ALU (registers);
    }

    public void initialize_registers () {
        debug ("Initializing CPU registers…");
        registers.set_af (0x01B0);
        registers.set_bc (0x0013);
        registers.set_de (0x00D8);
        registers.set_hl (0x014D);
        registers.set_sp (0xFFFE);
        //  registers.set_pc (0x0100);
        registers.set_pc (0x0000);
    }

    public void nop () { /* TODO */ }
    public void invalid_operation () { error ("Invalid operation"); }
    public void halt () { /* TODO */ }
    public void stop () { /* TODO */ }

    public void ld_a () { load_register (Replay.DMG.Processor.Registers.Register.A); }
    public void ld_b () { load_register (Replay.DMG.Processor.Registers.Register.B); }
    public void ld_c () { load_register (Replay.DMG.Processor.Registers.Register.C); }
    public void ld_d () { load_register (Replay.DMG.Processor.Registers.Register.D); }
    public void ld_e () { load_register (Replay.DMG.Processor.Registers.Register.E); }
    public void ld_h () { load_register (Replay.DMG.Processor.Registers.Register.H); }
    public void ld_l () { load_register (Replay.DMG.Processor.Registers.Register.L); }
    public void ld_bc () { load_register_pair (Replay.DMG.Processor.Registers.Register.C, Replay.DMG.Processor.Registers.Register.B); }
    public void ld_de () { load_register_pair (Replay.DMG.Processor.Registers.Register.E, Replay.DMG.Processor.Registers.Register.D); }
    public void ld_hl () { load_register_pair (Replay.DMG.Processor.Registers.Register.L, Replay.DMG.Processor.Registers.Register.H); }
    public void ld_sp () { /* load_register_pair ("LD SP, d16", Replay.DMG.Processor.Registers.Register.P, Replay.DMG.Processor.Registers.Register.S); */ }

    public void inc_a () { increment_register (Replay.DMG.Processor.Registers.Register.A); }
    public void inc_b () { increment_register (Replay.DMG.Processor.Registers.Register.B); }
    public void inc_c () { increment_register (Replay.DMG.Processor.Registers.Register.C); }
    public void inc_d () { increment_register (Replay.DMG.Processor.Registers.Register.D); }
    public void inc_e () { increment_register (Replay.DMG.Processor.Registers.Register.E); }
    public void inc_h () { increment_register (Replay.DMG.Processor.Registers.Register.H); }
    public void inc_l () { increment_register (Replay.DMG.Processor.Registers.Register.L); }
    public void inc_bc () { increment_register_pair (Replay.DMG.Processor.Registers.Register.BC); }
    public void inc_de () { increment_register_pair (Replay.DMG.Processor.Registers.Register.DE); }
    public void inc_hl () { increment_register_pair (Replay.DMG.Processor.Registers.Register.HL); }
    public void inc_sp () { /* increment_register_pair ("INC SP", Replay.DMG.Processor.Registers.Register.P, Replay.DMG.Processor.Registers.Register.S); */ }

    public void dec_a () { decrement_register (Replay.DMG.Processor.Registers.Register.A); }
    public void dec_b () { decrement_register (Replay.DMG.Processor.Registers.Register.B); }
    public void dec_c () { decrement_register (Replay.DMG.Processor.Registers.Register.C); }
    public void dec_d () { decrement_register (Replay.DMG.Processor.Registers.Register.D); }
    public void dec_e () { decrement_register (Replay.DMG.Processor.Registers.Register.E); }
    public void dec_h () { decrement_register (Replay.DMG.Processor.Registers.Register.H); }
    public void dec_l () { decrement_register (Replay.DMG.Processor.Registers.Register.L); }
    public void dec_bc () { decrement_register_pair (Replay.DMG.Processor.Registers.Register.BC); }
    public void dec_de () { decrement_register_pair (Replay.DMG.Processor.Registers.Register.DE); }
    public void dec_hl () { decrement_register_pair (Replay.DMG.Processor.Registers.Register.HL); }
    public void dec_sp () { /* decrement_register_pair ("DEC SP", Replay.DMG.Processor.Registers.Register.P, Replay.DMG.Processor.Registers.Register.S); */ }

    public void inc_hl_loc () {
        int address = registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL);
        mmu.write_byte (address, alu.inc (mmu.read_byte (address)));
        // increase_cycle (3);
    }

    public void dec_hl_loc () {
        int address = registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL);
        mmu.write_byte (address, alu.dec (mmu.read_byte (address)));
        // increase_cycle (3);
    }

    public void ld_hl_loc_d8 () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, d8 ()); }
    public void ld_bc_loc_a () { store_value_to_address (Replay.DMG.Processor.Registers.Register.BC, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_de_loc_a () { store_value_to_address (Replay.DMG.Processor.Registers.Register.DE, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }

    public void ld_a_de_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.DE))); }
    public void ld_a_hl_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void ld_b_hl_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void ld_c_hl_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void ld_d_hl_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void ld_e_hl_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void ld_h_hl_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void ld_l_hl_loc () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }

    public void ld_a_a () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_a_b () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_a_c () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_a_d () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_a_e () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_a_h () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_a_l () { load_value_to_register (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void ld_b_a () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_b_b () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_b_c () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_b_d () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_b_e () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_b_h () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_b_l () { load_value_to_register (Replay.DMG.Processor.Registers.Register.B, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void ld_c_a () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_c_b () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_c_c () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_c_d () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_c_e () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_c_h () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_c_l () { load_value_to_register (Replay.DMG.Processor.Registers.Register.C, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void ld_d_a () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_d_b () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_d_c () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_d_d () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_d_e () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_d_h () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_d_l () { load_value_to_register (Replay.DMG.Processor.Registers.Register.D, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void ld_e_a () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_e_b () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_e_c () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_e_d () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_e_e () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_e_h () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_e_l () { load_value_to_register (Replay.DMG.Processor.Registers.Register.E, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void ld_h_a () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_h_b () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_h_c () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_h_d () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_h_e () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_h_h () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_h_l () { load_value_to_register (Replay.DMG.Processor.Registers.Register.H, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void ld_l_a () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_l_b () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_l_c () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_l_d () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_l_e () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_l_h () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_l_l () { load_value_to_register (Replay.DMG.Processor.Registers.Register.L, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void di () {
        // TODO: Disable interrupts via interrupt manager
        // increase_cycle (1);
    }

    public void ei () {
        // TODO: Enable interrupts via interrupt manager
        // increase_cycle (1);
    }

    public void ld_hl_minus_a () {
        decrement_register_pair (Replay.DMG.Processor.Registers.Register.HL);
        mmu.write_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL), registers.get_register_value (Replay.DMG.Processor.Registers.Register.A));
    }

    public void ld_hl_plus_a () {
        increment_register_pair (Replay.DMG.Processor.Registers.Register.HL);
        mmu.write_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL), registers.get_register_value (Replay.DMG.Processor.Registers.Register.A));
    }

    public void ld_a_hl_minus () {
        decrement_register_pair (Replay.DMG.Processor.Registers.Register.HL);
        mmu.write_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A), registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL));
    }

    public void ld_a_hl_plus () {
        increment_register_pair (Replay.DMG.Processor.Registers.Register.HL);
        mmu.write_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A), registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL));
    }

    public void or_a () { or_register (Replay.DMG.Processor.Registers.Register.A); }
    public void or_b () { or_register (Replay.DMG.Processor.Registers.Register.B); }
    public void or_c () { or_register (Replay.DMG.Processor.Registers.Register.C); }
    public void or_d () { or_register (Replay.DMG.Processor.Registers.Register.D); }
    public void or_e () { or_register (Replay.DMG.Processor.Registers.Register.E); }
    public void or_h () { or_register (Replay.DMG.Processor.Registers.Register.H); }
    public void or_l () { or_register (Replay.DMG.Processor.Registers.Register.L); }
    public void or_hl_loc () {
        alu.or (mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL)));
    }
    public void or_d8 () {
        alu.or (d8 ());
        // increase_cycle (2);
    }

    public void and_a () { and_register (Replay.DMG.Processor.Registers.Register.A); }
    public void and_b () { and_register (Replay.DMG.Processor.Registers.Register.B); }
    public void and_c () { and_register (Replay.DMG.Processor.Registers.Register.C); }
    public void and_d () { and_register (Replay.DMG.Processor.Registers.Register.D); }
    public void and_e () { and_register (Replay.DMG.Processor.Registers.Register.E); }
    public void and_h () { and_register (Replay.DMG.Processor.Registers.Register.H); }
    public void and_l () { and_register (Replay.DMG.Processor.Registers.Register.L); }
    public void and_d8 () {
        alu.and (d8 ());
        // increase_cycle (2);
    }

    public void xor_a () { xor (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void xor_b () { xor (registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void xor_c () { xor (registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void xor_d () { xor (registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void xor_e () { xor (registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void xor_h () { xor (registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void xor_l () { xor (registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }
    public void xor_d8 () {
        alu.xor (d8 ());
        // increase_cycle ();
    }

    public void xor_hl_loc () {
        xor (mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL)));
        // increase_cycle ();
    }

    public void cpl () {
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, (~registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)) & 0xFF);
        // increase_cycle (1)
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

    public void ld_c_loc_a () { store_value_to_address_with_offset (Replay.DMG.Processor.Registers.Register.C, 0xFF00, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    
    public void ld_hl_loc_a () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void ld_hl_loc_b () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void ld_hl_loc_c () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void ld_hl_loc_d () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void ld_hl_loc_e () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void ld_hl_loc_h () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void ld_hl_loc_l () { store_value_to_address (Replay.DMG.Processor.Registers.Register.HL, registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }

    public void add_a_a () { add_register (Replay.DMG.Processor.Registers.Register.A); }
    public void add_a_b () { add_register (Replay.DMG.Processor.Registers.Register.B); }
    public void add_a_c () { add_register (Replay.DMG.Processor.Registers.Register.C); }
    public void add_a_d () { add_register (Replay.DMG.Processor.Registers.Register.D); }
    public void add_a_e () { add_register (Replay.DMG.Processor.Registers.Register.E); }
    public void add_a_h () { add_register (Replay.DMG.Processor.Registers.Register.H); }
    public void add_a_l () { add_register (Replay.DMG.Processor.Registers.Register.L); }
    public void add_a_d8 () { add_value_to_register (d8 ()); }
    public void add_a_hl_loc () { add_value_to_register (mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }

    public void add_hl_bc () { add_register_pair (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.BC); }
    public void add_hl_de () { add_register_pair (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.DE); }
    public void add_hl_hl () { add_register_pair (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.HL); }
    public void add_hl_sp () { /* TODO */ }

    public void adc_a_a () { adc (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void adc_a_b () { adc (registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void adc_a_c () { adc (registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void adc_a_d () { adc (registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void adc_a_e () { adc (registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void adc_a_h () { adc (registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void adc_a_l () { adc (registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }
    public void adc_a_hl_loc () { adc (mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void adc_a_d8 () { adc (Replay.DMG.Processor.Registers.Register.L); }

    public void sub_a () { sub (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void sub_b () { sub (registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void sub_c () { sub (registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void sub_d () { sub (registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void sub_e () { sub (registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void sub_h () { sub (registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void sub_l () { sub (registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }
    public void sub_hl_loc () { sub (mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }
    public void sub_d8 () { sub (d8 ()); }

    public void cp_a () { alu.cp (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)); }
    public void cp_b () { alu.cp (registers.get_register_value (Replay.DMG.Processor.Registers.Register.B)); }
    public void cp_c () { alu.cp (registers.get_register_value (Replay.DMG.Processor.Registers.Register.C)); }
    public void cp_d () { alu.cp (registers.get_register_value (Replay.DMG.Processor.Registers.Register.D)); }
    public void cp_e () { alu.cp (registers.get_register_value (Replay.DMG.Processor.Registers.Register.E)); }
    public void cp_h () { alu.cp (registers.get_register_value (Replay.DMG.Processor.Registers.Register.H)); }
    public void cp_l () { alu.cp (registers.get_register_value (Replay.DMG.Processor.Registers.Register.L)); }
    public void cp_hl_loc () { alu.cp (mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }

    public void sbc_a_a () { sbc (Replay.DMG.Processor.Registers.Register.A); }
    public void sbc_a_b () { sbc (Replay.DMG.Processor.Registers.Register.B); }
    public void sbc_a_c () { sbc (Replay.DMG.Processor.Registers.Register.C); }
    public void sbc_a_d () { sbc (Replay.DMG.Processor.Registers.Register.D); }
    public void sbc_a_e () { sbc (Replay.DMG.Processor.Registers.Register.E); }
    public void sbc_a_h () { sbc (Replay.DMG.Processor.Registers.Register.H); }
    public void sbc_a_l () { sbc (Replay.DMG.Processor.Registers.Register.L); }
    //  public void sbc_a_hl_loc () { sbc (mmu.read_byte (registers.get_register_value (Replay.DMG.Processor.Registers.Register.HL))); }

    public void rst_0 () { restart (0x00); }
    public void rst_1 () { restart (0x08); }
    public void rst_2 () { restart (0x10); }
    public void rst_3 () { restart (0x18); }
    public void rst_4 () { restart (0x20); }
    public void rst_5 () { restart (0x28); }
    public void rst_6 () { restart (0x30); }
    public void rst_7 () { restart (0x38); }

    public void ld_a16_loc_sp () {
        mmu.write_word (registers.get_pc () + 1, registers.get_register_value (Replay.DMG.Processor.Registers.Register.SP));
    }

    // ---- Private methods ---

    private void load_register (Replay.DMG.Processor.Registers.Register register) {
        registers.set_register_value (register, d8 ());
        // increase_cycle (2);
    }

    private void load_register_pair (Replay.DMG.Processor.Registers.Register register_low, Replay.DMG.Processor.Registers.Register register_high) {
        registers.set_register_value (register_low, d8 ());
        registers.set_register_value (register_high, d8 ());
        // increase_cycle (3);
    }

    private void increment_register (Replay.DMG.Processor.Registers.Register register) {
        registers.set_register_value (register, alu.inc (registers.get_register_value (register)));
        // increase_cycle (1);
    }

    private void increment_register_pair (Replay.DMG.Processor.Registers.Register register) {
        // TODO: Ensure 16bit register
        registers.set_register_value (register, alu.inc (registers.get_register_value (register)));
        // increase_cycle (2);
    }

    private void decrement_register (Replay.DMG.Processor.Registers.Register register) {
        registers.set_register_value (register, alu.dec (registers.get_register_value (register)));
        // increase_cycle (1);
    }

    private void decrement_register_pair (Replay.DMG.Processor.Registers.Register register) {
        // TODO: Ensure 16bit register
        registers.set_register_value (register, alu.dec (registers.get_register_value (register)));
        // increase_cycle (2);
    }

    private void store_value_to_address (Replay.DMG.Processor.Registers.Register dest, int value) {
        mmu.write_byte (registers.get_register_value (dest), value);
        // increase_cycle (1);
    }

    private void store_value_to_address_with_offset (Replay.DMG.Processor.Registers.Register dest, int dest_offset, int value) {
        mmu.write_byte (registers.get_register_value (dest) + dest_offset, value);
        // increase_cycle (1);
    }

    private void load_value_to_register (Replay.DMG.Processor.Registers.Register dest, int value) {
        registers.set_register_value (dest, value);
        // increase_cycle (1);
    }

    private void or_register (Replay.DMG.Processor.Registers.Register register) {
        alu.or (registers.get_register_value (register));
        // increase_cycle (1);
    }

    private void and_register (Replay.DMG.Processor.Registers.Register register) {
        alu.and (registers.get_register_value (register));
        // increase_cycle (1);
    }

    private void xor (int value) {
        alu.xor (value);
        // increase_cycle (1);
    }

    private void add_register (Replay.DMG.Processor.Registers.Register register) {
        alu.add (registers.get_register_value (register));
        // increase_cycle ();
    }

    private void add_value_to_register (int value) {
        alu.add (value);
        // increase_cycle ();
    }

    private void add_register_pair (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
        // TODO: Ensure 16bit register
        alu.add2 (dest, registers.get_register_value (src));
        // increase_cycle (2);
    }

    private void adc (int value) {
        alu.adc (value);
        // increase_cycle (2);
    }

    private void sub (int value) {
        alu.sub (value);
        // increase_cycle ();
    }

    public void sbc (Replay.DMG.Processor.Registers.Register register) {
        alu.sbc (registers.get_register_value (register));
    }

    private void restart (int address) {
        push_program_counter_to_stack ();
        registers.set_pc (address);
        // increase_cycle (4);
    }

    private void push_program_counter_to_stack () {
        var pc = registers.get_pc ();
        push_stack (pc >> 8);
        push_stack (pc);
    }

    private void push_stack (int value) {
        mmu.write_byte (registers.get_sp (), value);
        registers.decrement_sp ();
    }

    // ---- OLD ----

    public int get_pc () {
        return registers.get_pc ();
    }

    //  public void set_pc (int pc) {
    //      registers.set_pc (pc);
    //  }

    public int d8 () {
        // TODO: Account for cycles?
        return mmu.read_byte (registers.get_pc () + 1);
    }

    public int d16 () {
        // TODO: Account for cycles?
        return mmu.read_word (registers.get_pc () + 1);
    }

    public void execute_instruction () {
        int opcode = mmu.read_byte (registers.get_pc ());
        Replay.DMG.Processor.Operation operation = operations[opcode];
        if (operation == null) {
            return;
        }
        debug (operation.description);
        operation.execute (this);
    }

    //  public void nop () {
    //      // TODO
    //  }

    //  public void invalid_operation () {
    //      error ("Invalid operation");
    //  }

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
        registers.set_register_value (dest, registers.get_register_value (src));
    }

    public void ld_register_to_immediate_16 (Replay.DMG.Processor.Registers.Register src) {
        mmu.write_word (registers.get_pc () + 1, registers.get_register_value (src));
    }

    public void ld_memory_to_location (Replay.DMG.Processor.Registers.Register dest, int value) {
        mmu.write_byte (registers.get_register_value (dest), value);
    }

    public void push (Replay.DMG.Processor.Registers.Register register) {
        if (!register.is_16_bit_register ()) {
            error ("Must be a 16 bit register");
        }
        int sp = registers.get_sp ();
        int value = registers.get_register_value (register);
        sp--;
        // TODO: Account for cycles?
        int upper_byte = (value & 0xF0) >> 8;
        mmu.write_byte (sp, upper_byte);
        sp--;
        // TODO: Account for cycles?s
        int lower_byte = value & 0x0F;
        mmu.write_byte (sp, lower_byte);
        registers.set_sp (sp);
    }

    public void pop (Replay.DMG.Processor.Registers.Register register) {
        if (!register.is_16_bit_register ()) {
            error ("Must be a 16 bit register");
        }
        int sp = registers.get_sp ();
        // TODO: Account for cycles?
        int lower_byte = mmu.read_byte (sp);
        sp++;
        // TODO: Account for cycles?
        int upper_byte = mmu.read_byte (sp) << 8;
        sp++;
        registers.set_sp (sp);
        registers.set_register_value (register, lower_byte | upper_byte);
    }

    //  public void add (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
    //      if (dest.is_16_bit_register ()) {
    //          alu.add2 (dest, registers.get_register_value (src));
    //      } else {
    //          alu.add (registers.get_register_value (src));
    //      }
    //  }

    public void add_immediate_to_register (Replay.DMG.Processor.Registers.Register register, int value) {
        alu.add (value);
    }

    //  public void adc (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
    //      if (src.is_16_bit_register ()) {
    //          alu.adc (mmu.read_byte (registers.get_register_value (src)));
    //      } else {
    //          alu.adc (registers.get_register_value (src));
    //      }
    //  }

    public void adc_immediate_to_register (Replay.DMG.Processor.Registers.Register register, int value) {
        alu.adc (value);
    }

    //  public void sub (Replay.DMG.Processor.Registers.Register register) {
    //      alu.sub (registers.get_register_value (register));
    //  }

    //  public void sbc (Replay.DMG.Processor.Registers.Register register) {
    //      alu.sbc (registers.get_register_value (register));
    //  }

    public void and (Replay.DMG.Processor.Registers.Register register) {
        alu.and (registers.get_register_value (register));
    }

    public void or (Replay.DMG.Processor.Registers.Register register) {
        alu.or (registers.get_register_value (register));
    }

    //  public void xor (Replay.DMG.Processor.Registers.Register register) {
    //      alu.xor (registers.get_register_value (register));
    //  }

    //  public void cp (Replay.DMG.Processor.Registers.Register register) {
    //      alu.cp (registers.get_register_value (register));
    //  }

    public void inc (Replay.DMG.Processor.Registers.Register register) {
        if (register == Replay.DMG.Processor.Registers.Register.SP) {
            registers.increment_sp ();
        } else if (register == Replay.DMG.Processor.Registers.Register.PC) {
            registers.increment_pc ();
        } else {
            registers.set_register_value (register, alu.inc (registers.get_register_value (register)));
        }
    }

    // Increment the contents of memory at the address specified by the register
    public void inc_memory (Replay.DMG.Processor.Registers.Register register) {
        int address = registers.get_register_value (register);
        mmu.write_byte (address, mmu.read_byte (address) + 1);
    }

    public void dec (Replay.DMG.Processor.Registers.Register register) {
        if (register == Replay.DMG.Processor.Registers.Register.SP) {
            registers.decrement_sp ();
        } else if (register == Replay.DMG.Processor.Registers.Register.PC) {
            registers.decrement_pc ();
        } else {
            registers.set_register_value (register, alu.dec (registers.get_register_value (register)));
        }
    }

    // Decrements the contents of memory at the address specified by the register
    public void dec_memory (Replay.DMG.Processor.Registers.Register register) {
        int address = registers.get_register_value (register);
        mmu.write_byte (address, mmu.read_byte (address) - 1);
    }

    //  public int swap () {
    //      return -1;
    //  }

    //  public int daa () {
    //      return -1;
    //  }

    //  public int cpl () {
    //      return -1;
    //  }

    public void ccf () {
        var flag = Replay.DMG.Processor.FlagRegister.Flags.C;
        if (registers.get_flag (flag)) {
            registers.clear_flag (flag);
        } else {
            registers.set_flag (flag);
        }
    }

    public int scf () {
        return -1;
    }

    //  public void halt () {
    //      // TODO: ???
    //  }

    //  public void stop () {
    //      // TODO: ???
    //  }

    //  public int di () {
    //      return -1;
    //  }

    //  public int ei () {
    //      return -1;
    //  }

    //  public void rlca () {
    //      rlc (Replay.DMG.Processor.Registers.Register.A);
    //  }

    //  public void rlc (Replay.DMG.Processor.Registers.Register register) {
    //      int carry = (registers.get_register_value (register) & 0x80) >> 7;
    //      if (carry != 0) {
    //          registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      } else {
    //          registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      }
    //      registers.set_register_value (register, registers.get_register_value (register) << 1);
    //      registers.set_register_value (register, registers.get_register_value (register) + carry);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    //  }

    //  public void rla () {
    //      rl (Replay.DMG.Processor.Registers.Register.A);
    //  }

    //  public void rl (Replay.DMG.Processor.Registers.Register register) {
    //      int carry = registers.get_flag (Replay.DMG.Processor.FlagRegister.Flags.C) ? 1 : 0;
    //      if ((registers.get_register_value (register) & 0x80) != 0) {
    //          registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      } else {
    //          registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      }
    //      registers.set_register_value (register, registers.get_register_value (register) << 1);
    //      registers.set_register_value (register, registers.get_register_value (register) + carry);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    //  }

    //  public void rrca () {
    //      rrc (Replay.DMG.Processor.Registers.Register.A);
    //  }

    //  public void rrc (Replay.DMG.Processor.Registers.Register register) {
    //      int carry = (registers.get_register_value (register) & 0x01);
    //      if (carry != 0) {
    //          registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      } else {
    //          registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
    //      }
    //      registers.set_register_value (register, registers.get_register_value (register) >> 1);
    //      if (carry != 0) {
    //          registers.set_register_value (register, registers.get_register_value (register) | 0x80);
    //      }
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
    //      registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    //  }

    //  public int rra () {
    //      return -1;
    //  }

    //  public int rr () {
    //      return -1;
    //  }

    //  public int sla () {
    //      return -1;
    //  }

    //  public int sra () {
    //      return -1;
    //  }

    //  public int srl () {
    //      return -1;
    //  }

    //  public int bit () {
    //      return -1;
    //  }

    //  public new int set () {
    //      return -1;
    //  }

    //  public int res () {
    //      return -1;
    //  }

    //  public int jp () {
    //      return -1;
    //  }

    //  public int jr () {
    //      return -1;
    //  }

    //  public int call () {
    //      return -1;
    //  }

    //  public int rst () {
    //      return -1;
    //  }

    //  public int ret () {
    //      return -1;
    //  }

    //  public int reti () {
    //      return -1;
    //  }

}
