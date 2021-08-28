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

public class Replay.DMG.Graphics.GraphicsRegisters : GLib.Object, Replay.DMG.Memory.AddressSpace {

    private const int STAT_ADDRESS = 0xFF41; // LCD Status
    private const int SCY_ADDRESS = 0xFF42; // Scroll X
    private const int SCX_ADDRESS = 0xFF43; // Scroll Y
    private const int LY_ADDRESS = 0xFF44; // LCD Y Coordinate
    private const int LYC_ADDRESS = 0xFF45; // LY Compare
    private const int BGP_ADDRESS = 0xFF47; // BG Palette Data
    private const int OBP0_ADDRESS = 0xFF48; // Object Palette 0 Data
    private const int OBP1_ADDRESS = 0xFF49; // Object Palette 1 Data
    private const int WY_ADDRESS = 0xFF4A; // Window Y Position
    private const int WX_ADDRESS = 0xFF4B; // Window X Position

    public GraphicsRegisters () {
    }

    public bool accepts (int address) {
        switch (address) {
            case STAT_ADDRESS:
            case SCY_ADDRESS:
            case SCX_ADDRESS:
            case LY_ADDRESS:
            case LYC_ADDRESS:
            case BGP_ADDRESS:
            case OBP0_ADDRESS:
            case OBP1_ADDRESS:
            case WY_ADDRESS:
            case WX_ADDRESS:
                return true;
            default:
                return false;
        }
    }

    public int read_byte (int address) {
        // TODO
        return -1;
    }

    public void write_byte (int address, int value) {
        // TODO
    }

}
