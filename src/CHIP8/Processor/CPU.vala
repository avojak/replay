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
    private unowned Replay.CHIP8.IO.Keypad keypad;

    private Replay.CHIP8.Processor.Registers registers;
    private uint16 stack[16];
    private uint16 sp = 0;
    private uint8 delay_timer = 0;
    private uint8 sound_timer = 0;

    private uint16 instruction = 0;
    private int64 previous_instruction_update = 0;
    private int64 previous_timer_update = 0;

    public CPU (Replay.CHIP8.Memory.MMU mmu, Replay.CHIP8.Graphics.PPU ppu, Replay.CHIP8.IO.Keypad keypad) {
        this.mmu = mmu;
        this.ppu = ppu;
        this.keypad = keypad;
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
            //  uint8 instruction_type = (0xF000 & instruction) >> 12;
            //  if (instruction_type != 0x1 && instruction_type != 0x2 && instruction_type != 0xB) {
                next_instruction ();
            //  }
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
                        switch (get_n (instruction)) {
                            case 0x0:
                                8XY0 (instruction);
                                break;
                            case 0x1:
                                8XY1 (instruction);
                                break;
                            case 0x2:
                                8XY2 (instruction);
                                break;
                            case 0x3:
                                8XY3 (instruction);
                                break;
                            case 0x4:
                                8XY4 (instruction);
                                break;
                            case 0x5:
                                8XY5 (instruction);
                                break;
                            case 0x6:
                                8XY6 (instruction);
                                break;
                            case 0x7:
                                8XY7 (instruction);
                                break;
                            case 0xE:
                                8XYE (instruction);
                                break;
                            default:
                                critical ("Unknown instruction: %02x", instruction);
                                break;
                        }
                        break;
                    case 0x9:
                        9XY0 (instruction);
                        break;
                    case 0xA:
                        ANNN (instruction);
                        break;
                    case 0xB:
                        BNNN (instruction);
                        break;
                    case 0xC:
                        CXNN (instruction);
                        break;
                    case 0xD:
                        DXYN (instruction);
                        break;
                    case 0xE:
                        switch (get_nn (instruction)) {
                            case 0x9E:
                                EX9E (instruction);
                                break;
                            case 0xA1:
                                EXA1 (instruction);
                                break;
                            default:
                                critical ("Unknown instruction: %04x", instruction);
                                break;
                        }
                        break;
                    case 0xF:
                        switch (get_nn (instruction)) {
                            case 0x07:
                                FX07 (instruction);
                                break;
                            case 0x0A:
                                FX0A (instruction);
                                break;
                            case 0x15:
                                FX15 (instruction);
                                break;
                            case 0x18:
                                FX18 (instruction);
                                break;
                            case 0x1E:
                                FX1E (instruction);
                                break;
                            case 0x29:
                                FX29 (instruction);
                                break;
                            case 0x33:
                                FX33 (instruction);
                                break;
                            case 0x55:
                                FX55 (instruction);
                                break;
                            case 0x65:
                                FX65 (instruction);
                                break;
                            default:
                                critical ("Unknown instruction: %04x", instruction);
                                break;
                        }
                        break;
                    default:
                        critical ("Unknown instruction: %04x", instruction);
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

    // Set Vx = Vy
    private void 8XY0 (uint16 instruction) {
        set_vx (instruction, get_vy (instruction));
    }

    // Set Vx = Vx | Vy
    private void 8XY1 (uint16 instruction) {
        set_vx (instruction, get_vx (instruction) | get_vy (instruction));
    }

    // Set Vx = Vx & Vy
    private void 8XY2 (uint16 instruction) {
        set_vx (instruction, get_vx (instruction) & get_vy (instruction));
    }

    // Set Vx = Vx ^ Vy
    private void 8XY3 (uint16 instruction) {
        set_vx (instruction, get_vx (instruction) ^ get_vy (instruction));
    }

    // Set Vx = Vx + Vy
    private void 8XY4 (uint16 instruction) {
        uint16 sum = get_vx (instruction) + get_vy (instruction);
        set_vx (instruction, (uint8) (sum & 0x00FF));
        // If sum was greater than 255, set VF to 1
        registers.v[0xF] = sum > 0xFF ? 1 : 0;
    }

    // Set Vx = Vx - Vy
    private void 8XY5 (uint16 instruction) {
        registers.v[0xF] = get_vx (instruction) > get_vy (instruction) ? 1 : 0;
        set_vx (instruction, get_vx (instruction) - get_vy (instruction));
    }

    private void 8XY6 (uint16 instruction) {
        // TODO: Configurably set Vx = Vy first
        registers.v[0xF] = (get_vx (instruction) & 1) == 1 ? 1 : 0;
        set_vx (instruction, get_vx (instruction) >> 1);
    }

    // Set Vx = Vy - Vx
    private void 8XY7 (uint16 instruction) {
        registers.v[0xF] = get_vy (instruction) > get_vx (instruction) ? 1 : 0;
        set_vx (instruction, get_vy (instruction) - get_vx (instruction));
    }

    private void 8XYE (uint16 instruction) {
        // TODO: Configurably set Vx = Vy first
        registers.v[0xF] = (get_vx (instruction) & 0x80) >> 7 == 1 ? 1 : 0;
        set_vx (instruction, get_vx (instruction) << 1);
    }
    
    // Skip next instruction if Vx != Vy
    private void 9XY0 (uint16 instruction) {
        if (get_vx (instruction) != get_vy (instruction)) {
            next_instruction ();
        }
    }

    // Set I = NNN
    private void ANNN (uint16 instruction) {
        registers.i = get_nnn (instruction);
    }

    // Jump to NNN plus the value in V0
    private void BNNN (uint16 instruction) {
        // TODO: Configurable "quirk" here
        registers.pc = get_nnn (instruction) + registers.v[0];
    }

    // Set Vx = (a random number) & NN
    private void CXNN (uint16 instruction) {
        uint8 random = (uint8) GLib.Random.int_range (0, 0x100); // Random number in range [0x00 - 0xFF]
        set_vx (instruction, random & get_nn (instruction));
    }

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

    private void EX9E (uint16 instruction) {
        if (keypad.is_key_pressed (get_vx (instruction))) {
            next_instruction ();
        }
    }

    private void EXA1 (uint16 instruction) {
        if (!keypad.is_key_pressed (get_vx (instruction))) {
            next_instruction ();
        }
    }

    // Set Vx = delay timer
    private void FX07 (uint16 instruction) {
        set_vx (instruction, delay_timer);
    }

    private void FX0A (uint16 instruction) {
        uint8? key_pressed = keypad.get_key_presssed ();
        if (key_pressed != null) {
            set_vx (instruction, key_pressed);
        } else {
            registers.pc -= 2;
        }
    }

    // Set delay timer = Vx
    private void FX15 (uint16 instruction) {
        delay_timer = get_vx (instruction);
    }

    // Set sound timer = Vx
    private void FX18 (uint16 instruction) {
        sound_timer = get_vx (instruction);
    }

    // Add Vx to register I
    private void FX1E (uint16 instruction) {
        // TODO: Check for overflow?
        registers.i += get_vx (instruction);
    }

    private void FX29 (uint16 instruction) {
        registers.i = get_vx (instruction) * Replay.CHIP8.Memory.MMU.FONT_SPRITE_SIZE;
    }

    private void FX33 (uint16 instruction) {
        uint8 dec = get_vx (instruction);
        uint8 hundreds = (uint8) GLib.Math.floor (dec / 100);
        uint8 tens = (uint8) GLib.Math.floor ((dec - (hundreds * 100)) / 10);
        uint8 ones = dec - (hundreds * 100) - (tens * 10);
        mmu.set_byte (registers.i, hundreds);
        mmu.set_byte (registers.i + 1, tens);
        mmu.set_byte (registers.i + 2, ones);
    }

    private void FX55 (uint16 instruction) {
        for (int i = 0; i <= get_x (instruction); i++) {
            mmu.set_byte (registers.i + i, registers.v[i]);
            //  registers.i++;
        }
    }

    private void FX65 (uint16 instruction) {
        for (int i = 0; i <= get_x (instruction); i++) {
            registers.v[i] = mmu.get_byte (registers.i + i);
            //  registers.i++;
        }
    }


    private void next_instruction () {
        registers.pc += 2;
    }

    private uint8 get_x (uint16 instruction) {
        return (instruction & 0x0F00) >> 8;
    }

    private uint8 get_vx (uint16 instruction) {
        return registers.v[get_x (instruction)];
    }

    private void set_vx (uint16 instruction, uint8 value) {
        registers.v[get_x (instruction)] = value;
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