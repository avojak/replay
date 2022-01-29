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

    private const int INSTRUCTION_FREQUENCY = 60; // TODO: ???
    private const int TIMER_FREQUENCY = 60; // Timers are updated a frequency of 60Hz (i.e. once every 16.667ms)

    private unowned Replay.CHIP8.Memory.MMU mmu;
    private unowned Replay.CHIP8.Graphics.PPU ppu;

    private Replay.CHIP8.Processor.Registers registers;
    private uint16 stack[16];
    private uint16 sp = 0;
    private uint8 delay_timer = 0;
    private uint8 sound_timer = 0;

    private uint16 instruction = 0;
    private int64 previous_instruction_update = 0;
    private int64 previous_timer_update = 0;

    public CPU (Replay.CHIP8.Memory.MMU mmu, Replay.CHIP8.Graphics.PPU ppu) {
        this.mmu = mmu;
        this.ppu = ppu;
    }

    construct {
        registers = new Replay.CHIP8.Processor.Registers ();
        for (int i = 0; i < stack.length; i++) {
            stack[i] = 0;
        }
    }

    public void tick () {
        var now = GLib.get_real_time () / 1000;

        // Execute the instruction
        if ((now - previous_instruction_update) >= (1 / INSTRUCTION_FREQUENCY * 1000)) {
            instruction = (mmu.get_byte (registers.pc) << 8) | (mmu.get_byte (registers.pc + 1));
            debug ("$%03X: 0x%04X", registers.pc, instruction);
            uint8 instruction_type = (0xF000 & instruction) >> 12;
            if (instruction_type != 0x1 && instruction_type != 0x2 && instruction_type != 0xB) {
                next_instruction ();
            }
            execute (instruction);
            previous_instruction_update = now;
        }

        // Update timers
        if ((now - previous_timer_update) >= (1 / TIMER_FREQUENCY * 1000)) {
            if (delay_timer > 0) {
                delay_timer--;
            }
            if (sound_timer > 0) {
                sound_timer--;
            }
            previous_timer_update = now;
        }
    }

    private void execute (uint16 instruction) {
        // https://en.wikipedia.org/wiki/CHIP-8#Opcode_table
        switch (instruction) {
            case 0x00E0:
                ppu.clear ();
                break;
            case 0x00EE:
                // Return from a subroutine
                sp--;
                registers.pc = stack[sp];
                break;
            default:
                uint8 instruction_type = (0xF000 & instruction) >> 12;
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
                        ANNN (instruction);
                        break;
                    case 0xB:
                        break;
                    case 0xC:
                        break;
                    case 0xD:
                        DXYN (instruction);
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
    private void 1NNN (uint16 instruction) {
        registers.pc = get_nnn (instruction);
    }

    // Call subroutine at NNN
    private void 2NNN (uint16 instruction) {
        stack[sp] = registers.pc;
        sp++;
        registers.pc = get_nnn (instruction);
    }

    // Skip next instruction if Vx == NN
    private void 3XNN (uint16 instruction) {
        if (get_vx (instruction) == get_nn (instruction)) {
            next_instruction ();
        }
    }

    // Skip next instruction if Vx != NN
    private void 4XNN (uint16 instruction) {
        if (get_vx (instruction) != get_nn (instruction)) {
            next_instruction ();
        }
    }

    // Skip next instruction if Vx == Vy
    private void 5XY0 (uint16 instruction) {
        if (get_vx (instruction) == get_vy (instruction)) {
            next_instruction ();
        }
    }

    // Set Vx = NN
    private void 6XNN (uint16 instruction) {
        set_vx (instruction, get_nn (instruction));
    }

    // Add NN to Vx (Carry flag is not changed)
    private void 7XNN (uint16 instruction) {
        set_vx (instruction, get_vx (instruction) + get_nn (instruction));
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
    private void ANNN (uint16 instruction) {
        registers.i = get_nnn (instruction);
    }

    private void BNNN () { /* TODO */ }
    private void CXNN () { /* TODO */ }

    // Draw (Vx, Vy, N)
    private void DXYN (uint16 instruction) {
        uint8 vx = get_vx (instruction);
        uint8 vy = get_vy (instruction);
        uint8 height = get_n (instruction);

        registers.v[0x0F] = 0;
        if (ppu.draw_sprite (vx, vy, height, registers.i)) {
            registers.v[0x0F] = 1;
        }
    }

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

    private uint8 get_vx (uint16 instruction) {
        return registers.v[(instruction & 0x0F00) >> 8];
    }

    private void set_vx (uint16 instruction, uint8 value) {
        registers.v[(instruction & 0x0F00) >> 8] = value;
    }

    private uint8 get_vy (uint16 instruction) {
        return registers.v[(instruction & 0x00F0) >> 4];
    }

    private uint8 get_n (uint16 instruction) {
        return (uint8) (instruction & 0x000F);
    }

    private uint8 get_nn (uint16 instruction) {
        return (uint8) (instruction & 0x00FF);
    }

    private uint16 get_nnn (uint16 instruction) {
        return instruction & 0x0FFF;
    }

}