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

public class Replay.CHIP8.Graphics.Widgets.Display : Hdy.Window {

    public unowned Replay.MainWindow main_window { get; construct; }
    public unowned Replay.CHIP8.Graphics.PPU ppu { get; construct; }
    
    private const int BASE_SCALING = 8; // Base scaling factor to have a reasonable default display size 

    private Gtk.DrawingArea drawing_area;

    public Display (Replay.MainWindow main_window, Replay.CHIP8.Graphics.PPU ppu) {
        Object (
            deletable: false,
            resizable: false,
            title: Replay.CHIP8.Interpreter.COMMON_NAME,
            //  transient_for: main_window,
            modal: false,
            main_window: main_window,
            ppu: ppu
        );
    }

    construct {
        drawing_area = new Gtk.DrawingArea ();
        drawing_area.width_request = Replay.CHIP8.Graphics.PPU.WIDTH * BASE_SCALING;
        drawing_area.height_request = Replay.CHIP8.Graphics.PPU.HEIGHT * BASE_SCALING;
        drawing_area.draw.connect (on_draw);

        var header_bar = new Replay.CHIP8.Graphics.Widgets.HeaderBar ();
        //  var header_bar = new Hdy.HeaderBar () {
        //      title = Replay.CHIP8.Interpreter.COMMON_NAME,
        //      show_close_button = true,
        //      has_subtitle = false,
        //      decoration_layout = "close:" // Disable the maximize/restore button
        //  };
        //  header_bar.get_style_context ().add_class ("default-decoration");
        // TODO: Add settings dropdown here for updating scaling factor, speed, etc...

        var grid = new Gtk.Grid () {
            expand = true
        };
        grid.attach (header_bar, 0, 0);
        grid.attach (drawing_area, 0, 1);
        add (grid);

        this.key_press_event.connect ((event_key) => {
            var keyboard_key = event_key.str.up ()[0];
            if (Replay.CHIP8.IO.Keypad.KEYPAD_MAPPING.has_key (keyboard_key)) {
                key_pressed (keyboard_key);
                return false;
            }
        });
        this.key_release_event.connect ((event_key) => {
            var keyboard_key = event_key.str.up ()[0];
            if (Replay.CHIP8.IO.Keypad.KEYPAD_MAPPING.has_key (keyboard_key)) {
                key_released (keyboard_key);
                return false;
            }
        });

        show_all ();
    }

    private bool on_draw (Gtk.Widget da, Cairo.Context ctx) {
        ctx.save ();
        for (int row = 0; row < Replay.CHIP8.Graphics.PPU.HEIGHT; row++) {
            for (int col = 0; col < Replay.CHIP8.Graphics.PPU.WIDTH; col++) {
                int color = ppu.get_pixel (col, row); // * 255;
                ctx.set_source_rgb (color, color, color);
                ctx.new_path ();
                ctx.move_to (col * BASE_SCALING, row * BASE_SCALING);
                ctx.rel_line_to (BASE_SCALING, 0);
                ctx.rel_line_to (0, BASE_SCALING);
                ctx.rel_line_to (-BASE_SCALING, 0);
                ctx.close_path ();
                ctx.fill ();
            }
        }
        ctx.restore ();
        return true;
    }

    public signal void key_pressed (char key);
    public signal void key_released (char key);

}
