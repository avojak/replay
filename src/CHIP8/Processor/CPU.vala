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

public class Replay.CHIP8.Processor.CPU : GLib.Object {

    private unowned Replay.CHIP8.Memory.MMU mmu;
    private Replay.CHIP8.Processor.Registers registers;

    private short stack[16];
    private short sp;

    public CPU (Replay.CHIP8.Memory.MMU mmu) {
        this.mmu = mmu;
    }

    construct {
        registers = new Replay.CHIP8.Processor.Registers ();
    }

    public void initialize_registers () {
        debug ("Initializing CPU registers…");
        registers.pc = 0x200;
        registers.i = 0;
    }

    public void tick () {
        short instruction = (mmu.get_byte (registers.pc) << 8) | (mmu.get_byte (registers.pc + 1));
        execute (instruction);
        next_instruction ();
    }

    private void execute (short instruction) {
        // https://en.wikipedia.org/wiki/CHIP-8#Opcode_table
        switch (instruction) {
            case 0x00E0:
                // Clear the screen
                break;
            case 0x00EE:
                // Return from a subroutine
                break;
            default:
                char msb = (0xFF00 & instruction) >> 8;
                char lsb = 0x00FF & instruction;
                char instruction_type = (0xF0 & msb) >> 4;
                switch (instruction_type) {
                    case 0x0:
                        // Call machine code routine at address NNN
                        break;
                    case 0x1:
                        1NNN (instruction);
                        break;
                    case 0x2:
                        2NNN (instruction);
                        break;
                    case 0x3:
                        3XNN (instruction);
                        break;
                    case 0x4:
                        4XNN (instruction);
                        break;
                    case 0x5:
                        5XY0 (instruction);
                        break;
                    case 0x6:
                        6XNN (instruction);
                        break;
                    case 0x7:
                        7XNN (instruction);
                        break;
                    case 0x8:
                        break;
                    case 0x9:
                        break;
                    case 0xA:
                        
                        break;
                    case 0xB:
                        break;
                    case 0xC:
                        break;
                    case 0xD:
                        // Draw (Vx, Vy, N)
                        break;
                    case 0xE:
                        break;
                    case 0xF:
                        break;
                    default:
                        warning ("Unknown instruction: %02x", instruction);
                        break;
                }
                break;
        }
    }

    private void 0NNN () { }

    // Jump to address NNN
    private void 1NNN (short instruction) {
        registers.pc = instruction & 0x0FFF;
    }

    // Call subroutine at NNN
    private void 2NNN (short instruction) {
        stack[sp] = registers.pc;
        registers.pc = instruction & 0x0FFF;
    }

    // Skip next instruction if Vx == NN
    private void 3XNN (short instruction) {
        if (get_vx (instruction) == (instruction & 0x00FF)) {
            next_instruction ();
        }
    }

    // Skip next instruction if Vx != NN
    private void 4XNN (short instruction) {
        if (get_vx (instruction) != (instruction & 0x00FF)) {
            next_instruction ();
        }
    }

    // Skip next instruction if Vx == Vy
    private void 5XY0 (short instruction) {
        if (get_vx (instruction) == get_vy (instruction)) {
            next_instruction ();
        }
    }

    // Set Vx = NN
    private void 6XNN (short instruction) {
        set_vx (instruction, (char) (instruction & 0x00FF));
    }

    // Add NN to Vx (Carry flag is not changed)
    private void 7XNN (short instruction) {
        set_vx (instruction, get_vx (instruction) + (char) (instruction & 0x00FF));
    }

    private void 8XY0 () { /* TODO */ }
    private void 8XY1 () { /* TODO */ }
    private void 8XY2 () { /* TODO */ }
    private void 8XY3 () { /* TODO */ }
    private void 8XY4 () { /* TODO */ }
    private void 8XY5 () { /* TODO */ }
    private void 8XY6 () { /* TODO */ }
    private void 8XY7 () { /* TODO */ }
    private void 8XYE () { /* TODO */ }
    private void 9XY0 () { /* TODO */ }

    // Set I = NNN
    private void ANNN (short instruction) {
        registers.i = instruction & 0x0FFF;
    }

    private void BNNN () { /* TODO */ }
    private void CXNN () { /* TODO */ }
    private void DXYN () { /* TODO */ }
    private void EX9E () { /* TODO */ }
    private void EXA1 () { /* TODO */ }
    private void FX07 () { /* TODO */ }
    private void FX0A () { /* TODO */ }
    private void FX15 () { /* TODO */ }
    private void FX18 () { /* TODO */ }
    private void FX1E () { /* TODO */ }
    private void FX29 () { /* TODO */ }
    private void FX33 () { /* TODO */ }
    private void FX55 () { /* TODO */ }
    private void FX65 () { /* TODO */ }

    private void next_instruction () {
        registers.pc += 2;
    }

    private char get_vx (short instruction) {
        return registers.v[(instruction & 0x0F00) >> 8];
    }

    private void set_vx (short instruction, char value) {
        registers.v[(instruction & 0x0F00) >> 8] = value;
    }

    private char get_vy (short instruction) {
        return registers.v[(instruction & 0x00F0) >> 4];
    }

    public signal void draw_pixel (int x, int y, char pixel);

}