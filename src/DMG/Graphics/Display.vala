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

public class Replay.DMG.Graphics.Display : Hdy.Window {

    public unowned Replay.MainWindow main_window { get; construct; }

    private const int WIDTH = 160;
    private const int HEIGHT = 144;
    private const int BASE_SCALING = 2; // Base scaling factor to have a reasonble default display size 

    private const int SIZE = 30; // TODO: Temprorary

    private Gtk.DrawingArea drawing_area;

    public Display (Replay.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: "Game Boy",
            //  transient_for: main_window,
            modal: false,
            main_window: main_window
        );
    }

    construct {
        drawing_area = new Gtk.DrawingArea ();
        drawing_area.width_request = WIDTH * BASE_SCALING;
        drawing_area.height_request = HEIGHT * BASE_SCALING;
        drawing_area.draw.connect (on_draw);

        var header_bar = new Hdy.HeaderBar () {
            title = "Game Boy",
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

    private bool on_draw (Gtk.Widget da, Cairo.Context ctx) {
        ctx.set_source_rgb (0, 0, 0);

        ctx.set_line_width (SIZE / 4);
        ctx.set_tolerance (0.1);

        ctx.set_line_join (Cairo.LineJoin.ROUND);
        ctx.set_dash (new double[] {SIZE / 4.0, SIZE / 4.0}, 0);
        stroke_shapes (ctx, 0, 0);

        ctx.set_dash (null, 0);
        stroke_shapes (ctx, 0, 3 * SIZE);

        ctx.set_line_join (Cairo.LineJoin.BEVEL);
        stroke_shapes (ctx, 0, 6 * SIZE);

        ctx.set_line_join (Cairo.LineJoin.MITER);
        stroke_shapes(ctx, 0, 9 * SIZE);

        fill_shapes (ctx, 0, 12 * SIZE);

        ctx.set_line_join (Cairo.LineJoin.BEVEL);
        fill_shapes (ctx, 0, 15 * SIZE);
        ctx.set_source_rgb (1, 0, 0);
        stroke_shapes (ctx, 0, 15 * SIZE);

        return true;
    }

    private void stroke_shapes (Cairo.Context ctx, int x, int y) {
        this.draw_shapes (ctx, x, y, ctx.stroke);
    }

    private void fill_shapes (Cairo.Context ctx, int x, int y) {
        this.draw_shapes (ctx, x, y, ctx.fill);
    }

    private delegate void DrawMethod ();

    private void draw_shapes (Cairo.Context ctx, int x, int y, DrawMethod draw_method) {
        ctx.save ();

        ctx.new_path ();
        ctx.translate (x + SIZE, y + SIZE);
        bowtie (ctx);
        draw_method ();

        ctx.new_path ();
        ctx.translate (3 * SIZE, 0);
        square (ctx);
        draw_method ();

        ctx.new_path ();
        ctx.translate (3 * SIZE, 0);
        triangle (ctx);
        draw_method ();

        ctx.new_path ();
        ctx.translate (3 * SIZE, 0);
        inf (ctx);
        draw_method ();

        ctx.restore();
    }

    private void triangle (Cairo.Context ctx) {
        ctx.move_to (SIZE, 0);
        ctx.rel_line_to (SIZE, 2 * SIZE);
        ctx.rel_line_to (-2 * SIZE, 0);
        ctx.close_path ();
    }

    private void square (Cairo.Context ctx) {
        ctx.move_to (0, 0);
        ctx.rel_line_to (2 * SIZE, 0);
        ctx.rel_line_to (0, 2 * SIZE);
        ctx.rel_line_to (-2 * SIZE, 0);
        ctx.close_path ();
    }

    private void bowtie (Cairo.Context ctx) {
        ctx.move_to (0, 0);
        ctx.rel_line_to (2 * SIZE, 2 * SIZE);
        ctx.rel_line_to (-2 * SIZE, 0);
        ctx.rel_line_to (2 * SIZE, -2 * SIZE);
        ctx.close_path ();
    }

    private void inf (Cairo.Context ctx) {
        ctx.move_to (0, SIZE);
        ctx.rel_curve_to (0, SIZE, SIZE, SIZE, 2 * SIZE, 0);
        ctx.rel_curve_to (SIZE, -SIZE, 2 * SIZE, -SIZE, 2 * SIZE, 0);
        ctx.rel_curve_to (0, SIZE, -SIZE, SIZE, -2 * SIZE, 0);
        ctx.rel_curve_to (-SIZE, -SIZE, -2 * SIZE, -SIZE, -2 * SIZE, 0);
        ctx.close_path ();
    }

}