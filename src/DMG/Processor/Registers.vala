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

public class Replay.DMG.Processor.Registers : GLib.Object {

    private int a;
    private int b;
    private int c;
    private int d;
    private int e;
    private int h;
    private int l;
    private int sp; // stack pointer
    private int pc; // program counter

    private FlagRegister flag_register = new FlagRegister ();

    public int get_a () {
        return a;
    }

    public int get_b () {
        return b;
    }

    public int get_c () {
        return c;
    }

    public int get_d () {
        return d;
    }

    public int get_e () {
        return e;
    }

    public int get_h () {
        return h;
    }

    public int get_l () {
        return l;
    }

    public int get_af () {
        return a << 8 | flag_register.get_byte ();
    }

    public int get_bc () {
        return b << 8 | c;
    }

    public int get_de () {
        return d << 8 | e;
    }

    public int get_hl () {
        return h << 8 | l;
    }

    public int get_sp () {
        return sp;
    }

    public int get_pc () {
        return pc;
    }

    public void set_a (int a) {
        this.a = Replay.Utils.BitUtils.check_byte_argument (a, "a");
    }

    public void set_b (int b) {
        this.b = Replay.Utils.BitUtils.check_byte_argument (b, "b");
    }

    public void set_c (int c) {
        this.c = Replay.Utils.BitUtils.check_byte_argument (c, "c");
    }

    public void set_d (int d) {
        this.d = Replay.Utils.BitUtils.check_byte_argument (d, "d");
    }

    public void set_e (int e) {
        this.e = Replay.Utils.BitUtils.check_byte_argument (e, "e");
    }

    public void set_h (int h) {
        this.h = Replay.Utils.BitUtils.check_byte_argument (h, "h");
    }

    public void set_l (int l) {
        this.l = Replay.Utils.BitUtils.check_byte_argument (l, "l");
    }

    public void set_af (int af) {
        Replay.Utils.BitUtils.check_word_argument (af, "af");
        a = Replay.Utils.BitUtils.get_msb (af);
        flag_register.set_byte (Replay.Utils.BitUtils.get_lsb (af));
    }

    public void set_bc (int bc) {
        Replay.Utils.BitUtils.check_word_argument (bc, "bc");
        b = Replay.Utils.BitUtils.get_msb (bc);
        c = Replay.Utils.BitUtils.get_lsb (bc);
    }

    public void set_de (int de) {
        Replay.Utils.BitUtils.check_word_argument (de, "de");
        d = Replay.Utils.BitUtils.get_msb (de);
        e = Replay.Utils.BitUtils.get_lsb (de);
    }

    public void set_hl (int hl) {
        Replay.Utils.BitUtils.check_word_argument (hl, "hl");
        h = Replay.Utils.BitUtils.get_msb (hl);
        l = Replay.Utils.BitUtils.get_lsb (hl);
    }

    public void set_sp (int sp) {
        this.sp = Replay.Utils.BitUtils.check_word_argument (sp, "sp");
    }

    public void set_pc (int pc) {
        this.pc = Replay.Utils.BitUtils.check_word_argument (pc, "pc");
    }

    public void increment_sp () {
        sp = (sp + 1) & 0xFFFF;
    }

    public void increment_pc () {
        pc = (pc + 1) & 0xFFFF;
    }

    public void decrement_sp () {
        sp = (sp - 1) & 0xFFFF;
    }

    public void set_flag (Replay.DMG.Processor.Flags flag) {
        switch (flag) {
            case Z:
                flag_register.set_z (true);
                break;
            case N:
                flag_register.set_n (true);
                break;
            case H:
                flag_register.set_h (true);
                break;
            case C:
                flag_register.set_c (true);
                break;
            default:
                assert_not_reached ();
        }
    }

    public void clear_flag (Replay.DMG.Processor.Flags flag) {
        switch (flag) {
            case Z:
                flag_register.set_z (false);
                break;
            case N:
                flag_register.set_n (false);
                break;
            case H:
                flag_register.set_h (false);
                break;
            case C:
                flag_register.set_c (false);
                break;
            default:
                assert_not_reached ();
        }
    }

    public bool get_flag (Replay.DMG.Processor.Flags flag) {
        switch (flag) {
            case Z:
                return flag_register.is_z ();
            case N:
                return flag_register.is_n ();
            case H:
                return flag_register.is_h ();
            case C:
                return flag_register.is_c ();
            default:
                assert_not_reached ();
        }
    }

}