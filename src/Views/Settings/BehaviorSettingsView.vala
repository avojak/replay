/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
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

public class Replay.Views.Settings.BehaviorSettingsView : Replay.Views.Settings.AbstractSettingsView {

    private Gtk.FileChooserButton user_rom_dir_entry;
    private Gtk.FileChooserButton save_data_dir_entry;

    construct {
        var game_data_header_label = new Granite.HeaderLabel (_("Game Data"));

        var user_rom_dir_label = new Gtk.Label (_("ROM Directory:")) {
            halign = Gtk.Align.END
        };
        user_rom_dir_entry = new Gtk.FileChooserButton (_("Select Your ROM Directory\u2026"), Gtk.FileChooserAction.SELECT_FOLDER) {
            hexpand = true
        };
        user_rom_dir_entry.set_uri (GLib.File.new_for_path (GLib.Environment.get_home_dir ()).get_uri ());
        user_rom_dir_entry.file_set.connect (() => {
            debug (user_rom_dir_entry.get_uri ());
            // TODO
        });

        var save_data_dir_label = new Gtk.Label (_("Save Data Directory:")) {
            halign = Gtk.Align.END
        };
        save_data_dir_entry = new Gtk.FileChooserButton (_("Select Your Save Data Directory\u2026"), Gtk.FileChooserAction.SELECT_FOLDER) {
            hexpand = true
        };
        save_data_dir_entry.set_uri (GLib.File.new_for_path (GLib.Environment.get_home_dir ()).get_uri ());
        save_data_dir_entry.file_set.connect (() => {
            debug (save_data_dir_entry.get_uri ());
            // TODO
        });

        attach (game_data_header_label, 0, 0, 2);
        attach (user_rom_dir_label, 0, 1);
        attach (user_rom_dir_entry, 1, 1);
        attach (save_data_dir_label, 0, 2);
        attach (save_data_dir_entry, 1, 2);
    }

}
