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

public class Replay.Widgets.Dialogs.DebugDialog : Granite.Dialog {

    public unowned Replay.MainWindow main_window { get; construct; }

    public DebugDialog (Replay.MainWindow main_window) {
        Object (
            deletable: true,
            resizable: true,
            title: "Debug",
            transient_for: main_window,
            modal: false,
            main_window: main_window
        );
    }

    construct {
        var form_grid = new Gtk.Grid ();
        form_grid.margin = 30;
        form_grid.row_spacing = 6;
        form_grid.column_spacing = 12;

        var registers_header_label = new Granite.HeaderLabel ("Registers");
        var register_af_label = new Gtk.Label ("AF");
        var register_af_value = new Gtk.Label ("0xFFF0");
        var register_bc_label = new Gtk.Label ("BC");
        var register_bc_value = new Gtk.Label ("0xFFFF");
        var register_de_label = new Gtk.Label ("DE");
        var register_de_value = new Gtk.Label ("0xFFFF");
        var register_hl_label = new Gtk.Label ("HL");
        var register_hl_value = new Gtk.Label ("0xFFFF");

        var flags_header_label = new Granite.HeaderLabel ("Flags");
        var flag_z_label = new Gtk.Label ("Z");
        var flag_z_value = new Gtk.Label ("0");
        var flag_n_label = new Gtk.Label ("N");
        var flag_n_value = new Gtk.Label ("0");
        var flag_h_label = new Gtk.Label ("H");
        var flag_h_value = new Gtk.Label ("0");
        var flag_c_label = new Gtk.Label ("C");
        var flag_c_value = new Gtk.Label ("0");

        var interrupts_header_label = new Granite.HeaderLabel ("Interrupts");

        form_grid.attach (registers_header_label, 0, 0, 4, 1);
        form_grid.attach (register_af_label, 0, 1, 1, 1);
        form_grid.attach (register_af_value, 0, 2, 1, 1);
        form_grid.attach (register_bc_label, 1, 1, 1, 1);
        form_grid.attach (register_bc_value, 1, 2, 1, 1);
        form_grid.attach (register_de_label, 2, 1, 1, 1);
        form_grid.attach (register_de_value, 2, 2, 1, 1);
        form_grid.attach (register_hl_label, 3, 1, 1, 1);
        form_grid.attach (register_hl_value, 3, 2, 1, 1);

        form_grid.attach (flags_header_label, 0, 3, 4, 1);
        form_grid.attach (flag_z_label, 0, 4, 1, 1);
        form_grid.attach (flag_z_value, 0, 5, 1, 1);
        form_grid.attach (flag_n_label, 1, 4, 1, 1);
        form_grid.attach (flag_n_value, 1, 5, 1, 1);
        form_grid.attach (flag_h_label, 2, 4, 1, 1);
        form_grid.attach (flag_h_value, 2, 5, 1, 1);
        form_grid.attach (flag_c_label, 3, 4, 1, 1);
        form_grid.attach (flag_c_value, 3, 5, 1, 1);

        form_grid.attach (interrupts_header_label, 0, 6, 4, 1);

        var body = get_content_area ();
        body.add (form_grid);

        int main_window_width, main_window_height, main_window_x, main_window_y;
        main_window.get_size (out main_window_width, out main_window_height);
        main_window.get_position (out main_window_x, out main_window_y);

        move (main_window_x + main_window_width, main_window_y);
    }

}
