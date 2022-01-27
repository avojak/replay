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

public class Replay.CHIP8.Graphics.Display : Hdy.Window {

    public unowned Replay.MainWindow main_window { get; construct; }

    private const int WIDTH = 64;
    private const int HEIGHT = 32;
    private const int BASE_SCALING = 2; // Base scaling factor to have a reasonble default display size 

    private const int SIZE = 30; // TODO: Temprorary

    private char[,] data;
    private Gtk.DrawingArea drawing_area;

    public Display (Replay.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: Replay.CHIP8.Interpreter.COMMON_NAME,
            //  transient_for: main_window,
            modal: false,
            main_window: main_window
        );
    }

    construct {
        data = new char[HEIGHT, WIDTH];
        for (int row = 0; row < data.length[0]; row++) {
            for (int col = 0; col < data.length[1]; col++) {
                data[row, col] = 0x00;
            }
        }

        drawing_area = new Gtk.DrawingArea ();
        drawing_area.width_request = WIDTH * BASE_SCALING;
        drawing_area.height_request = HEIGHT * BASE_SCALING;
        drawing_area.draw.connect (on_draw);

        var header_bar = new Hdy.HeaderBar () {
            title = Replay.CHIP8.Interpreter.COMMON_NAME,
            show_close_button = true,
            has_subtitle = false
        };
        header_bar.get_style_context ().add_class ("default-decoration");
        // TODO: Add settings dropdown here for updating scaling factor, speed, etc...

        var grid = new Gtk.Grid () {
            expand = true
        };
        grid.attach (header_bar, 0, 0);
        grid.attach (drawing_area, 0, 1);

        add (grid);
        show_all ();
    }

    public void set_pixel (int x, int y, char pixel) {
        data[y,x] = pixel & 0x01;
    }

    public void clear () {
        for (int row = 0; row < data.length[0]; row++) {
            for (int col = 0; col < data.length[1]; col++) {
                data[row, col] = 0x00;
            }
        }
    }

    private bool on_draw (Gtk.Widget da, Cairo.Context ctx) {
        ctx.save ();
        for (int row = 0; row < data.length[0]; row++) {
            for (int col = 0; col < data.length[1]; col++) {
                int color = data[row, col]; // * 255
                ctx.set_source_rgb (color, color, color);
                ctx.new_path ();
                ctx.move_to (col, row);
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

}
