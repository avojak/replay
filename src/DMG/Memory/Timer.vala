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

public class Replay.DMG.Memory.Timer : GLib.Object, Replay.DMG.Memory.AddressSpace {

    private const int DIV_ADDRESS = 0xFF04;  // Divider register
    private const int TIMA_ADDRESS = 0xFF05; // Timer counter
    private const int TMA_ADDRESS = 0xFF06;  // Timer modulo
    private const int TAC_ADDRESS = 0xFF07;  // Timer control

    private int div;
    private int tima;
    private int tma;
    private int tac;

    public Timer () {
    }

    public bool accepts (int address) {
        return address >= DIV_ADDRESS && address <= TAC_ADDRESS;
    }

    public int read_byte (int address) {
        switch (address) {
            case DIV_ADDRESS:
                return div;
            case TIMA_ADDRESS:
                return tima;
            case TMA_ADDRESS:
                return tma;
            case TAC_ADDRESS:
                return tac;
            default:
                assert_not_reached ();
        }
    }

    public void write_byte (int address, int value) {
        switch (address) {
            case DIV_ADDRESS:
                div = value;
                break;
            case TIMA_ADDRESS:
                tima = value;
                break;
            case TMA_ADDRESS:
                tma = value;
                break;
            case TAC_ADDRESS:
                tac = value;
                break;
            default:
                assert_not_reached ();
        }
    }

}
