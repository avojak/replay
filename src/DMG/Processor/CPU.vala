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
        operations[0x08] = new Replay.DMG.Processor.Operation ("LD (a16), SP", (cpu) => { cpu.ld_register_to_immediate_16 (Replay.DMG.Processor.Registers.Register.SP); }, 3, 20);
        operations[0x09] = new Replay.DMG.Processor.Operation ("ADD HL, BC", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        operations[0x0A] = new Replay.DMG.Processor.Operation ("LD A, (BC)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        operations[0x0B] = new Replay.DMG.Processor.Operation ("DEC BC", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.BC); }, 1, 8);
        operations[0x0C] = new Replay.DMG.Processor.Operation ("INC C", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x0D] = new Replay.DMG.Processor.Operation ("DEC C", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x0E] = new Replay.DMG.Processor.Operation ("LD C, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.C, cpu.d8 ()); }, 2, 8);
        operations[0x0F] = new Replay.DMG.Processor.Operation ("RRCA", (cpu) => { cpu.rrca (); }, 1, 4);
        operations[0x10] = new Replay.DMG.Processor.Operation ("STOP", (cpu) => { cpu.stop (); }, 2, 4);
        operations[0x11] = new Replay.DMG.Processor.Operation ("LD DE, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.DE, cpu.d16 ()); }, 3, 12);
        operations[0x12] = new Replay.DMG.Processor.Operation ("LD (DE), A", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.DE, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        operations[0x13] = new Replay.DMG.Processor.Operation ("INC DE", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        operations[0x14] = new Replay.DMG.Processor.Operation ("INC D", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x15] = new Replay.DMG.Processor.Operation ("DEC D", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x16] = new Replay.DMG.Processor.Operation ("LD D, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.D, cpu.d8 ()); }, 2, 8);
        operations[0x17] = new Replay.DMG.Processor.Operation ("RLA", (cpu) => { cpu.rla (); }, 1, 4);
        operations[0x18] = null; // TODO
        operations[0x19] = new Replay.DMG.Processor.Operation ("ADD HL, DE", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        operations[0x1A] = new Replay.DMG.Processor.Operation ("LD A, (DE)", (cpu) => { cpu.ld_memory_to_register (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        operations[0x1B] = new Replay.DMG.Processor.Operation ("DEC DE", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.DE); }, 1, 8);
        operations[0x1C] = new Replay.DMG.Processor.Operation ("INC E", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x1D] = new Replay.DMG.Processor.Operation ("DEC E", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x1E] = new Replay.DMG.Processor.Operation ("LD E, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.E, cpu.d8 ()); }, 2, 8);
        operations[0x1F] = null; // TODO
        operations[0x20] = null; // TODO
        operations[0x21] = new Replay.DMG.Processor.Operation ("LD HL, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.HL, cpu.d16 ()); }, 3, 12);
        operations[0x22] = new Replay.DMG.Processor.Operation ("LD (HL+), A", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        operations[0x23] = new Replay.DMG.Processor.Operation ("INC HL", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x24] = new Replay.DMG.Processor.Operation ("INC H", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x25] = new Replay.DMG.Processor.Operation ("DEC H", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x26] = new Replay.DMG.Processor.Operation ("LD H, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.H, cpu.d8 ()); }, 2, 8);
        operations[0x27] = null; // TODO
        operations[0x28] = null; // TODO
        operations[0x29] = new Replay.DMG.Processor.Operation ("ADD HL, HL", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x2A] = new Replay.DMG.Processor.Operation ("LD A, (HL+)", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x2B] = new Replay.DMG.Processor.Operation ("DEC HL", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x2C] = new Replay.DMG.Processor.Operation ("INC L", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x2D] = new Replay.DMG.Processor.Operation ("DEC L", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x2E] = new Replay.DMG.Processor.Operation ("LD L, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.L, cpu.d8 ()); }, 2, 8);
        operations[0x2F] = null; // TODO
        operations[0x30] = null; // TODO
        operations[0x31] = new Replay.DMG.Processor.Operation ("LD SP, d16", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.SP, cpu.d16 ()); }, 3, 12);
        operations[0x32] = new Replay.DMG.Processor.Operation ("LD (HL-), A", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
        operations[0x33] = new Replay.DMG.Processor.Operation ("INC SP", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.SP); }, 1, 8);
        operations[0x34] = new Replay.DMG.Processor.Operation ("INC (HL)", (cpu) => { cpu.inc_memory (Replay.DMG.Processor.Registers.Register.HL); }, 1, 12);
        operations[0x35] = new Replay.DMG.Processor.Operation ("DEC (HL)", (cpu) => { cpu.dec_memory (Replay.DMG.Processor.Registers.Register.HL); }, 1, 12);
        operations[0x36] = new Replay.DMG.Processor.Operation ("LD (HL), d8", (cpu) => { cpu.ld_memory_to_location (Replay.DMG.Processor.Registers.Register.HL, cpu.d8 ()); }, 2, 12);
        operations[0x37] = null; // TODO
        operations[0x38] = null; // TODO
        operations[0x39] = new Replay.DMG.Processor.Operation ("ADD HL, SP", (cpu) => { cpu.add (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.SP); }, 1, 8);
        operations[0x3A] = new Replay.DMG.Processor.Operation ("LD A, (HL-)", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.HL); cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.HL); }, 1, 8);
        operations[0x3B] = new Replay.DMG.Processor.Operation ("DEC SP", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.SP); }, 1, 8);
        operations[0x3C] = new Replay.DMG.Processor.Operation ("INC A", (cpu) => { cpu.inc (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x3D] = new Replay.DMG.Processor.Operation ("DEC A", (cpu) => { cpu.dec (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x3E] = new Replay.DMG.Processor.Operation ("LD A, d8", (cpu) => { cpu.ld_immediate_to_register (Replay.DMG.Processor.Registers.Register.A, cpu.d8 ()); }, 2, 8);
        operations[0x3F] = new Replay.DMG.Processor.Operation ("CCF", (cpu) => { cpu.ccf (); }, 1, 4);
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
        operations[0x70] = new Replay.DMG.Processor.Operation ("LD (HL), B", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.B); }, 1, 8);
        operations[0x71] = new Replay.DMG.Processor.Operation ("LD (HL), C", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.C); }, 1, 8);
        operations[0x72] = new Replay.DMG.Processor.Operation ("LD (HL), D", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.D); }, 1, 8);
        operations[0x73] = new Replay.DMG.Processor.Operation ("LD (HL), E", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.E); }, 1, 8);
        operations[0x74] = new Replay.DMG.Processor.Operation ("LD (HL), H", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.H); }, 1, 8);
        operations[0x75] = new Replay.DMG.Processor.Operation ("LD (HL), L", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.L); }, 1, 8);
        operations[0x76] = new Replay.DMG.Processor.Operation ("HALT", (cpu) => { cpu.halt (); }, 1, 4);
        operations[0x77] = new Replay.DMG.Processor.Operation ("LD (HL), A", (cpu) => { cpu.ld_register_to_memory (Replay.DMG.Processor.Registers.Register.HL, Replay.DMG.Processor.Registers.Register.A); }, 1, 8);
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
        operations[0x89] = new Replay.DMG.Processor.Operation ("ADC A, C", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x8A] = new Replay.DMG.Processor.Operation ("ADC A, D", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x8B] = new Replay.DMG.Processor.Operation ("ADC A, E", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x8C] = new Replay.DMG.Processor.Operation ("ADC A, H", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x8D] = new Replay.DMG.Processor.Operation ("ADC A, L", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x8E] = null; // TODO
        operations[0x8F] = new Replay.DMG.Processor.Operation ("ADC A, A", (cpu) => { cpu.adc (Replay.DMG.Processor.Registers.Register.A, Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x90] = new Replay.DMG.Processor.Operation ("SUB B", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x91] = new Replay.DMG.Processor.Operation ("SUB C", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x92] = new Replay.DMG.Processor.Operation ("SUB D", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x93] = new Replay.DMG.Processor.Operation ("SUB E", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x94] = new Replay.DMG.Processor.Operation ("SUB H", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x95] = new Replay.DMG.Processor.Operation ("SUB L", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x96] = null; // TODO
        operations[0x97] = new Replay.DMG.Processor.Operation ("SUB A", (cpu) => { cpu.sub (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0x98] = new Replay.DMG.Processor.Operation ("SBC B", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0x99] = new Replay.DMG.Processor.Operation ("SBC C", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0x9A] = new Replay.DMG.Processor.Operation ("SBC D", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0x9B] = new Replay.DMG.Processor.Operation ("SBC E", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0x9C] = new Replay.DMG.Processor.Operation ("SBC H", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0x9D] = new Replay.DMG.Processor.Operation ("SBC L", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0x9E] = null; // TODO
        operations[0x9F] = new Replay.DMG.Processor.Operation ("SBC A", (cpu) => { cpu.sbc (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0xA0] = new Replay.DMG.Processor.Operation ("AND B", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0xA1] = new Replay.DMG.Processor.Operation ("AND C", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0xA2] = new Replay.DMG.Processor.Operation ("AND D", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0xA3] = new Replay.DMG.Processor.Operation ("AND E", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0xA4] = new Replay.DMG.Processor.Operation ("AND H", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0xA5] = new Replay.DMG.Processor.Operation ("AND L", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0xA6] = null; // TODO
        operations[0xA7] = new Replay.DMG.Processor.Operation ("AND A", (cpu) => { cpu.and (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0xA8] = new Replay.DMG.Processor.Operation ("XOR B", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0xA9] = new Replay.DMG.Processor.Operation ("XOR C", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0xAA] = new Replay.DMG.Processor.Operation ("XOR D", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0xAB] = new Replay.DMG.Processor.Operation ("XOR E", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0xAC] = new Replay.DMG.Processor.Operation ("XOR H", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0xAD] = new Replay.DMG.Processor.Operation ("XOR L", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0xAE] = null; // TODO
        operations[0xAF] = new Replay.DMG.Processor.Operation ("XOR A", (cpu) => { cpu.xor (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0xB0] = new Replay.DMG.Processor.Operation ("OR B", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0xB1] = new Replay.DMG.Processor.Operation ("OR C", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0xB2] = new Replay.DMG.Processor.Operation ("OR D", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0xB3] = new Replay.DMG.Processor.Operation ("OR E", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0xB4] = new Replay.DMG.Processor.Operation ("OR H", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0xB5] = new Replay.DMG.Processor.Operation ("OR L", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0xB6] = null; // TODO
        operations[0xB7] = new Replay.DMG.Processor.Operation ("OR A", (cpu) => { cpu.or (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0xB8] = new Replay.DMG.Processor.Operation ("CP B", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.B); }, 1, 4);
        operations[0xB9] = new Replay.DMG.Processor.Operation ("CP C", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.C); }, 1, 4);
        operations[0xBA] = new Replay.DMG.Processor.Operation ("CP D", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.D); }, 1, 4);
        operations[0xBB] = new Replay.DMG.Processor.Operation ("CP E", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.E); }, 1, 4);
        operations[0xBC] = new Replay.DMG.Processor.Operation ("CP H", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.H); }, 1, 4);
        operations[0xBD] = new Replay.DMG.Processor.Operation ("CP L", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.L); }, 1, 4);
        operations[0xBE] = null; // TODO
        operations[0xBF] = new Replay.DMG.Processor.Operation ("CP A", (cpu) => { cpu.cp (Replay.DMG.Processor.Registers.Register.A); }, 1, 4);
        operations[0xC0] = null; // TODO
        operations[0xC1] = new Replay.DMG.Processor.Operation ("POP BC", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.BC); }, 1, 12);
        operations[0xC2] = null; // TODO
        operations[0xC3] = null; // TODO
        operations[0xC4] = null; // TODO
        operations[0xC5] = new Replay.DMG.Processor.Operation ("PUSH BC", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.BC); }, 1, 16);
        operations[0xC6] = new Replay.DMG.Processor.Operation ("ADD A, d8", (cpu) => { cpu.add_immediate_to_register (Replay.DMG.Processor.Registers.Register.A, cpu.d8 ()); }, 2, 8);
        operations[0xC7] = null; // TODO
        operations[0xC8] = null; // TODO
        operations[0xC9] = null; // TODO
        operations[0xCA] = null; // TODO
        operations[0xCB] = null; // TODO
        operations[0xCC] = null; // TODO
        operations[0xCD] = null; // TODO
        operations[0xCE] = new Replay.DMG.Processor.Operation ("ADC A, d8", (cpu) => { cpu.adc_immediate_to_register (Replay.DMG.Processor.Registers.Register.A, cpu.d8 ()); }, 2, 8);
        operations[0xCF] = null; // TODO
        operations[0xD0] = null; // TODO
        operations[0xD1] = new Replay.DMG.Processor.Operation ("POP DE", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.DE); }, 1, 12);
        operations[0xD2] = null; // TODO
        operations[0xD3] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xD4] = null; // TODO
        operations[0xD5] = new Replay.DMG.Processor.Operation ("PUSH DE", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.DE); }, 1, 16);
        operations[0xD6] = null; // TODO
        operations[0xD7] = null; // TODO
        operations[0xD8] = null; // TODO
        operations[0xD9] = null; // TODO
        operations[0xDA] = null; // TODO
        operations[0xDB] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xDC] = null; // TODO
        operations[0xDD] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xDE] = null; // TODO
        operations[0xDF] = null; // TODO
        operations[0xE0] = null; // TODO
        operations[0xE1] = new Replay.DMG.Processor.Operation ("POP HL", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.HL); }, 1, 12);
        operations[0xE2] = null; // TODO
        operations[0xE3] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xE4] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xE5] = new Replay.DMG.Processor.Operation ("PUSH HL", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.HL); }, 1, 16);
        operations[0xE6] = null; // TODO
        operations[0xE7] = null; // TODO
        operations[0xE8] = null; // TODO
        operations[0xE9] = null; // TODO
        operations[0xEA] = null; // TODO
        operations[0xEB] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xEC] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xED] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xEE] = null; // TODO
        operations[0xEF] = null; // TODO
        operations[0xF0] = null; // TODO
        operations[0xF1] = new Replay.DMG.Processor.Operation ("POP AF", (cpu) => { cpu.pop (Replay.DMG.Processor.Registers.Register.AF); }, 1, 12);
        operations[0xF2] = null; // TODO
        operations[0xF3] = null; // TODO
        operations[0xF4] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xF5] = new Replay.DMG.Processor.Operation ("PUSH AF", (cpu) => { cpu.push (Replay.DMG.Processor.Registers.Register.AF); }, 1, 16);
        operations[0xF6] = null; // TODO
        operations[0xF7] = null; // TODO
        operations[0xF8] = null; // TODO
        operations[0xF9] = null; // TODO
        operations[0xFA] = null; // TODO
        operations[0xFB] = null; // TODO
        operations[0xFC] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xFD] = new Replay.DMG.Processor.Operation ("XXX", (cpu) => { cpu.invalid_operation (); }, 0, 0);
        operations[0xFE] = null; // TODO
        operations[0xFF] = null; // TODO
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

    public int get_pc () {
        return registers.get_pc ();
    }

    public void set_pc (int pc) {
        registers.set_pc (pc);
    }

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

    public void nop () {
        // TODO
    }

    public void invalid_operation () {
        error ("Invalid operation");
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

    public void add (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
        if (dest.is_16_bit_register ()) {
            alu.add2 (dest, registers.get_register_value (src));
        } else {
            alu.add (registers.get_register_value (src));
        }
    }

    public void add_immediate_to_register (Replay.DMG.Processor.Registers.Register register, int value) {
        alu.add (value);
    }

    public void adc (Replay.DMG.Processor.Registers.Register dest, Replay.DMG.Processor.Registers.Register src) {
        if (src.is_16_bit_register ()) {
            alu.adc (mmu.read_byte (registers.get_register_value (src)));
        } else {
            alu.adc (registers.get_register_value (src));
        }
    }

    public void adc_immediate_to_register (Replay.DMG.Processor.Registers.Register register, int value) {
        alu.adc (value);
    }

    public void sub (Replay.DMG.Processor.Registers.Register register) {
        alu.sub (registers.get_register_value (register));
    }

    public void sbc (Replay.DMG.Processor.Registers.Register register) {
        alu.sbc (registers.get_register_value (register));
    }

    public void and (Replay.DMG.Processor.Registers.Register register) {
        alu.and (registers.get_register_value (register));
    }

    public void or (Replay.DMG.Processor.Registers.Register register) {
        alu.or (registers.get_register_value (register));
    }

    public void xor (Replay.DMG.Processor.Registers.Register register) {
        alu.xor (registers.get_register_value (register));
    }

    public void cp (Replay.DMG.Processor.Registers.Register register) {
        alu.cp (registers.get_register_value (register));
    }

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

    public int swap () {
        return -1;
    }

    public int daa () {
        return -1;
    }

    public int cpl () {
        return -1;
    }

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

}
