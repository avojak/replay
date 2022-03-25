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

 public class Replay.Views.Settings.GamesSettingsView : Granite.SimpleSettingsPage {

    private Gtk.FileChooserButton user_rom_dir_entry;

    public GamesSettingsView () {
        Object (
            activatable: false,
            description: "Preferences for games in the library",
            header: null,
            icon_name: "applications-games",
            title: "Games"
        );
    }

    construct {
        // TODO:
        // [x] User ROM directory
        // [ ] Auto-save time

        var user_rom_dir_label = new Gtk.Label (_("ROM Directory:")) {
            halign = Gtk.Align.END
        };

        user_rom_dir_entry = new Gtk.FileChooserButton (_("Select Your ROM Directory\u2026"), Gtk.FileChooserAction.SELECT_FOLDER) {
            hexpand = true
        };
        user_rom_dir_entry.set_uri (GLib.File.new_for_path (GLib.Environment.get_home_dir ()).get_uri ());
        user_rom_dir_entry.file_set.connect (() => {
            debug (user_rom_dir_entry.get_uri ());
        });

        content_area.attach (user_rom_dir_label, 0, 0);
        content_area.attach (user_rom_dir_entry, 1, 0);

        var reset_button = new Gtk.Button.with_label (_("Restore Default Settings"));

        action_area.add (reset_button);
        action_area.set_child_secondary (reset_button, true);

        reset_button.clicked.connect (() => {
            // TODO
        });

        load_settings ();
    }

    private void load_settings () {
        // TODO
        var user_rom_dir = Replay.Application.settings.get_string ("user-rom-directory");
        if (user_rom_dir.strip ().length > 0) {
            user_rom_dir_entry.set_uri (GLib.File.new_for_path (user_rom_dir).get_uri ());
        }
    }

}
