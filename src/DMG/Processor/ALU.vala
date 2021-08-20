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

public class Replay.DMG.Processor.ALU : GLib.Object {

    // ALU = Arithmetic Logic Unit

    // http://www.devrs.com/gb/files/opcodes.html

    public unowned Replay.DMG.Processor.Registers registers;

    public ALU (Replay.DMG.Processor.Registers registers) {
        this.registers = registers;
    }

    // INC s
    public int inc (int value) {
        if ((value & 0x0F) == 0x0F) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        value++;
        if (value != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        return value;
    }

    // DEC s
    public int dec (int value) {
        if ((value & 0x0F) != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        value--;
        if (value != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        return value;
    }

    // ADD A, s
    public void add (int value) {
        int result = registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) + value;
        if ((result & 0xFF00) != 0) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, result & 0xFF);
        if (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        if ((registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) & 0x0F) + (value & 0x0F) > 0x0F) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
    }

    // ADD A, s
    public void adc (int value) {
        if (registers.get_flag (Replay.DMG.Processor.FlagRegister.Flags.C)) {
            value++;
        }
        int result = registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) + value;
        if ((result & 0xFF00) != 0) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        if (value == registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        if ((registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) & 0x0F) + (value & 0x0F) > 0x0F) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, result & 0xFF);
    }

    // SUB s
    public void sub (int value) {
        registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        if (value > registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        if ((value & 0x0F) > (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) & 0x0F)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) - value);
        if (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
    }

    // SBC A, s
    public void sbc (int value) {
        if (registers.get_flag (Replay.DMG.Processor.FlagRegister.Flags.C)) {
            value++;
        }
        registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        if (value > registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        if (value == registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        if ((value & 0x0F) > (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) & 0x0F)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) - value);
    }

    // AND s
    public void and (int value) {
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) & value);
        if (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    }

    // OR s
    public void or (int value) {
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) | value);
        if (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    }

    // XOR s
    public void xor (int value) {
        registers.set_register_value (Replay.DMG.Processor.Registers.Register.A, registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) ^ value);
        if (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) != 0) {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
    }

    // CP s
    public void cp (int value) {
        if (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) == value) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.Z);
        }
        if (value > registers.get_register_value (Replay.DMG.Processor.Registers.Register.A)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        if ((value & 0x0F) > (registers.get_register_value (Replay.DMG.Processor.Registers.Register.A) & 0x0F)) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
    }

    public void add2 (Replay.DMG.Processor.Registers.Register destination, int value) {
        long result = registers.get_register_value (destination) + value;
        if ((result & 0xFFFF0000) != 0) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.C);
        }
        registers.set_register_value (destination, (int) (result & 0xFFFF));
        if ((registers.get_register_value (destination) & 0x0F) + (value & 0x0F) > 0x0F) {
            registers.set_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        } else {
            registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.H);
        }
        registers.clear_flag (Replay.DMG.Processor.FlagRegister.Flags.N);
    }

}
