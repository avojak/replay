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

public class Replay.MainLayout : Gtk.Grid {

    public unowned Replay.MainWindow window { get; construct; }

    private Replay.Widgets.HeaderBar header_bar;
    private Gtk.Grid control_container;
    private Gtk.Grid emulator_display_container;
    private Gtk.Grid emulator_debug_container;

    public MainLayout (Replay.MainWindow window) {
        Object (
            window: window
        );
    }

    construct {
        header_bar = new Replay.Widgets.HeaderBar ();
        header_bar.get_style_context ().add_class ("default-decoration");
        header_bar.debug_button_clicked.connect (() => {
            debug_button_clicked ();
        });

        var rom_file_entry = new Gtk.FileChooserButton (_("Select ROM File\u2026"), Gtk.FileChooserAction.OPEN);
        rom_file_entry.hexpand = true;
        rom_file_entry.sensitive = true;
        rom_file_entry.set_uri (GLib.Environment.get_home_dir ());

        var start_button = new Gtk.Button.with_label ("Start");
        start_button.clicked.connect (() => {
            start_button_clicked (rom_file_entry.get_uri ());
        });
        var stop_button = new Gtk.Button.with_label ("Stop");
        stop_button.clicked.connect (() => {
            stop_button_clicked ();
        });

        control_container = new Gtk.Grid () {
            hexpand = true,
            column_spacing = 8,
            row_spacing = 8,
            margin = 8
        };
        control_container.attach (rom_file_entry, 0, 0);
        control_container.attach (start_button, 1, 0);
        control_container.attach (stop_button, 2, 0);

        emulator_display_container = new Gtk.Grid () {
            expand = true,
            margin = 8,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        emulator_debug_container = new Gtk.Grid ();

        var emulator_container = new Gtk.Grid () {
            expand = true
        };
        emulator_container.attach (emulator_display_container, 0, 0);
        emulator_container.attach (emulator_debug_container, 1, 0);

        attach (header_bar, 0, 0);
        attach (control_container, 0, 1);
        attach (emulator_container, 0, 2);

        show_all ();
    }

    public void set_emulator_display (Gtk.Grid display) {
        emulator_display_container.attach (display, 0, 0);
    }

    public void remove_emulator_display (Gtk.Grid display) {
        emulator_display_container.remove (display);
    }

    public void set_emulator_debug_display (Gtk.Grid debug_display) {
        emulator_debug_container.attach (debug_display, 0, 0);
    }

    public void remove_emulator_debug_display (Gtk.Grid debug_display) {
        emulator_debug_container.remove (debug_display);
    }

    public signal void start_button_clicked (string uri_rom);
    public signal void stop_button_clicked ();

    public signal void debug_button_clicked ();

}
