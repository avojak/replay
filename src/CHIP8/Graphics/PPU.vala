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

public class Replay.CHIP8.Graphics.PPU : GLib.Object {

    public const int WIDTH = 64;
    public const int HEIGHT = 32;
    private const int SPRITE_WIDTH = 8;
    
    private unowned Replay.CHIP8.Memory.MMU mmu;

    private uint8[] data;

    public PPU (Replay.CHIP8.Memory.MMU mmu) {
        this.mmu = mmu;
    }

    construct {
        data = new uint8[WIDTH * HEIGHT];
        initialize_data ();
    }

    private void initialize_data () {
        for (int i = 0; i < data.length; i++) {
            data[i] = 0x00;
        }
    }

    public bool draw_sprite (uint8 vx, uint8 vy, uint8 height, uint16 index_register_value) {
        lock (data) {
            // Wrap the starting position, but not the actual drawing of the sprite
            int sprite_x = vx % WIDTH;
            int sprite_y = vy % HEIGHT;
            bool are_pixels_unset = false;
            
            // Iterate over each row of the sprite for the height specified
            for (int row = 0; row < height; row++) {
                // Extract the current row of the sprite to be drawn
                uint8 sprite_row = mmu.get_byte (index_register_value + row);
                // Calculate the absolute pixel position y-coordinate
                int pixel_y = sprite_y + row;
                // Iterate over each column of the sprite
                for (int col = 0; col < SPRITE_WIDTH; col++) {
                    // Calculate the aboslute pixel position x-coordinate
                    int pixel_x = sprite_x + col;
                    // Calculate the index in the data array for the x,y coordinate pair
                    int data_index = pixel_x + (pixel_y * WIDTH);
                    // Get the current pixel value
                    uint8 current_pixel_value = data[data_index];
                    // Get the requested new pixel value via bitmask
                    uint8 sprite_pixel = (sprite_row & (0x80 >> col));
                    // Bit-shift such that the value is either a 0 or 1
                    sprite_pixel = sprite_pixel >> (7 - col);
                    // If the pixel is already drawn, and we request it to be drawn again, clear it
                    if (sprite_pixel == 1 && current_pixel_value == 1) {
                        data[data_index] = 0;
                        are_pixels_unset = true;
                    } 
                    // If the pixel is not already drawn, and we request it to be drawn, draw it
                    if (sprite_pixel == 1 && current_pixel_value == 0) {
                        data[data_index] = 1;
                    }
                    // Check if we're at the edge of the screen
                    if (pixel_x == WIDTH - 1) {
                        break;
                    }
                }
                // Check if we're at the edge of the screen
                if (pixel_y == HEIGHT - 1) {
                    break;
                }
            }

            // XXX: Debugging
            //  print ("+");
            //  for (int i = 0; i < WIDTH; i++) {
            //      print ("-");
            //  }
            //  print ("+\n");
            //  for (int row = 0; row < HEIGHT; row++) {
            //      var sb = new StringBuilder ("|");
            //      for (int col = 0; col < WIDTH; col++) {
            //          int index = col + (row * WIDTH);
            //          sb.append (data[index] == 1 ? "X" : " ");
            //      }
            //      print (sb.str + "|\n");
            //  }
            //  print ("+");
            //  for (int i = 0; i < WIDTH; i++) {
            //      print ("-");
            //  }
            //  print ("+\n\n");

            return are_pixels_unset;
        }
    }

    public uint8 get_pixel (int x, int y) {
        lock (data) {
            return data[x + (y * WIDTH)];
        }
    }

    public void clear () {
        initialize_data ();
    }

}