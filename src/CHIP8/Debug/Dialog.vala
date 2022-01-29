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

public class Replay.CHIP8.Debug.Dialog : Granite.Dialog {

    public unowned Replay.CHIP8.Graphics.Widgets.Display display { get; construct; }

    private Gtk.Label pc_register_label;
    private Gtk.Label i_register_label;
    private Gtk.Label v0_register_label;
    private Gtk.Label v1_register_label;
    private Gtk.Label v2_register_label;
    private Gtk.Label v3_register_label;
    private Gtk.Label v4_register_label;
    private Gtk.Label v5_register_label;
    private Gtk.Label v6_register_label;
    private Gtk.Label v7_register_label;
    private Gtk.Label v8_register_label;
    private Gtk.Label v9_register_label;
    private Gtk.Label vA_register_label;
    private Gtk.Label vB_register_label;
    private Gtk.Label vC_register_label;
    private Gtk.Label vD_register_label;
    private Gtk.Label vE_register_label;
    private Gtk.Label vF_register_label;

    public Dialog (Replay.CHIP8.Graphics.Widgets.Display display) {
        Object (
            deletable: false,
            resizable: false,
            title: "Debug",
            modal: false,
            display: display
        );
    }

    construct {
        var instruction_header_label = new Granite.HeaderLabel ("Instruction");

        var registers_grid = new Gtk.Grid ();
        var registers_header_label = new Granite.HeaderLabel ("Registers");
        pc_register_label = create_value_label ();
        i_register_label = create_value_label ();
        v0_register_label = create_value_label ();
        v1_register_label = create_value_label ();
        v2_register_label = create_value_label ();
        v3_register_label = create_value_label ();
        v4_register_label = create_value_label ();
        v5_register_label = create_value_label ();
        v6_register_label = create_value_label ();
        v7_register_label = create_value_label ();
        v8_register_label = create_value_label ();
        v9_register_label = create_value_label ();
        vA_register_label = create_value_label ();
        vB_register_label = create_value_label ();
        vC_register_label = create_value_label ();
        vD_register_label = create_value_label ();
        vE_register_label = create_value_label ();
        vF_register_label = create_value_label ();

        registers_grid.attach (registers_header_label, 0, 0, 2, 1);
        registers_grid.attach (create_label ("PC:"), 0, 1);
        registers_grid.attach (pc_register_label, 1, 1);
        registers_grid.attach (create_label ("I:"),  0, 2);
        registers_grid.attach (i_register_label, 1, 2);
        registers_grid.attach (create_label ("V0:"), 0, 3);
        registers_grid.attach (v0_register_label, 1, 3);
        registers_grid.attach (create_label ("V1:"), 0, 4);
        registers_grid.attach (v1_register_label, 1, 4);
        registers_grid.attach (create_label ("V2:"), 0, 5);
        registers_grid.attach (v2_register_label, 1, 5);
        registers_grid.attach (create_label ("V3:"), 0, 6);
        registers_grid.attach (v3_register_label, 1, 6);
        registers_grid.attach (create_label ("V4:"), 0, 7);
        registers_grid.attach (v4_register_label, 1, 7);
        registers_grid.attach (create_label ("V5:"), 0, 8);
        registers_grid.attach (v5_register_label, 1, 8);
        registers_grid.attach (create_label ("V6:"), 0, 9);
        registers_grid.attach (v6_register_label, 1, 9);
        registers_grid.attach (create_label ("V7:"), 0, 10);
        registers_grid.attach (v7_register_label, 1, 10);
        registers_grid.attach (create_label ("V8:"), 0, 11);
        registers_grid.attach (v8_register_label, 1, 11);
        registers_grid.attach (create_label ("V9:"), 0, 12);
        registers_grid.attach (v9_register_label, 1, 12);
        registers_grid.attach (create_label ("VA:"), 0, 13);
        registers_grid.attach (vA_register_label, 1, 13);
        registers_grid.attach (create_label ("VB:"), 0, 14);
        registers_grid.attach (vB_register_label, 1, 14);
        registers_grid.attach (create_label ("VC:"), 0, 15);
        registers_grid.attach (vC_register_label, 1, 15);
        registers_grid.attach (create_label ("VD:"), 0, 16);
        registers_grid.attach (vD_register_label, 1, 16);
        registers_grid.attach (create_label ("VE:"), 0, 17);
        registers_grid.attach (vE_register_label, 1, 17);
        registers_grid.attach (create_label ("VF:"), 0, 18);
        registers_grid.attach (vF_register_label, 1, 18);

        var form_grid = new Gtk.Grid ();
        form_grid.margin = 30;
        form_grid.row_spacing = 6;
        form_grid.column_spacing = 12;

        form_grid.attach (registers_grid, 0, 0);

        var body = get_content_area ();
        body.add (form_grid);

        //  int display_width, display_height, display_x, display_y;
        //  display.get_size (out display_width, out display_height);
        //  display.get_position (out display_x, out display_y);

        //  move (display_x + display_width, display_y);
    }

    private Gtk.Label create_label (string text) {
        return new Gtk.Label (text) {
            halign = Gtk.Align.END
            //  justify = Gtk.Justification.RIGHT
        };
    }

    private Gtk.Label create_value_label () {
        return new Gtk.Label ("") {
            halign = Gtk.Align.END
        };
    }

    public void update () {
        update_registers ();
    }

    private void update_registers () {
        pc_register_label.set_text ("%04X".printf (0));
        i_register_label.set_text ("%04X".printf (0));
        v0_register_label.set_text ("%02X".printf (0));
        v1_register_label.set_text ("%02X".printf (0));
        v2_register_label.set_text ("%02X".printf (0));
        v3_register_label.set_text ("%02X".printf (0));
        v4_register_label.set_text ("%02X".printf (0));
        v5_register_label.set_text ("%02X".printf (0));
        v6_register_label.set_text ("%02X".printf (0));
        v7_register_label.set_text ("%02X".printf (0));
        v8_register_label.set_text ("%02X".printf (0));
        v9_register_label.set_text ("%02X".printf (0));
        vA_register_label.set_text ("%02X".printf (0));
        vB_register_label.set_text ("%02X".printf (0));
        vC_register_label.set_text ("%02X".printf (0));
        vD_register_label.set_text ("%02X".printf (0));
        vE_register_label.set_text ("%02X".printf (0));
        vF_register_label.set_text ("%02X".printf (0));
    }

}
