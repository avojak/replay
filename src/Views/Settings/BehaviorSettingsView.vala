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

    // TODO: Add option for copying ROMs to ROM directory if not present (i.e. auto import?)

    construct {
        var general_header_label = new Granite.HeaderLabel (_("General"));

        var download_boxart_label = new Gtk.Label (_("Automatically download box art:")) {
            halign = Gtk.Align.END
        };
        var download_boxart_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Replay.Application.settings.bind ("download-boxart", download_boxart_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var game_data_header_label = new Granite.HeaderLabel (_("Game Data"));

        var user_rom_dir_label = new Gtk.Label (_("ROM directory:")) {
            halign = Gtk.Align.END
        };
        user_rom_dir_entry = new Gtk.FileChooserButton (_("Select Your ROM Directory\u2026"), Gtk.FileChooserAction.SELECT_FOLDER) {
            //  hexpand = true
            halign = Gtk.Align.START
        };
        user_rom_dir_entry.set_uri (GLib.File.new_for_path (GLib.Environment.get_home_dir ()).get_uri ());
        user_rom_dir_entry.file_set.connect (() => {
            debug (user_rom_dir_entry.get_uri ());
            // TODO
        });

        var save_data_dir_label = new Gtk.Label (_("Save data directory:")) {
            halign = Gtk.Align.END
        };
        save_data_dir_entry = new Gtk.FileChooserButton (_("Select Your Save Data Directory\u2026"), Gtk.FileChooserAction.SELECT_FOLDER) {
            //  hexpand = true
            halign = Gtk.Align.START
        };
        save_data_dir_entry.set_uri (GLib.File.new_for_path (GLib.Environment.get_home_dir ()).get_uri ());
        save_data_dir_entry.file_set.connect (() => {
            debug (save_data_dir_entry.get_uri ());
            // TODO
        });

        var playback_header_label = new Granite.HeaderLabel (_("Playback"));

        var bios_label = new Gtk.Label (_("Boot BIOS:")) {
            halign = Gtk.Align.END
        };
        var bios_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Replay.Application.settings.bind ("emu-boot-bios", bios_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var focus_lost_label = new Gtk.Label (_("Pause on focus lost:")) {
            halign = Gtk.Align.END
        };
        var focus_lost_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Replay.Application.settings.bind ("handle-window-focus-change", focus_lost_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var speed_label = new Gtk.Label (_("Emulation speed:")) {
            halign = Gtk.Align.END
        };
        var speed_spin_button = create_spin_button (0.1, 3.0, 1.0);

        attach (general_header_label, 0, 0, 2);
        attach (download_boxart_label, 0, 1);
        attach (download_boxart_switch, 1, 1);
        attach (game_data_header_label, 0, 2, 2);
        attach (user_rom_dir_label, 0, 3);
        attach (user_rom_dir_entry, 1, 3);
        attach (save_data_dir_label, 0, 4);
        attach (save_data_dir_entry, 1, 4);
        attach (playback_header_label, 0, 5, 2);
        attach (bios_label, 0, 6);
        attach (bios_switch, 1, 6);
        attach (focus_lost_label, 0, 7);
        attach (focus_lost_switch, 1, 7);
        attach (speed_label, 0, 8);
        attach (speed_spin_button, 1, 8);
    }

    private Gtk.SpinButton create_spin_button (double min_value, double max_value, double default_value) {
        var button = new Gtk.SpinButton.with_range (min_value, max_value, 0.1) {
            //  secondary_icon_name = "input-pixel-symbolic",
            //  secondary_icon_activatable = false,
            //  secondary_icon_sensitive = false,
            //  hexpand = true
            halign = Gtk.Align.START
        };
        button.set_value (default_value);
        return button;
    }

}
