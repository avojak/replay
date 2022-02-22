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

public class Replay.Services.GameLibrary : GLib.Object {

    private static Replay.Services.GameLibrary _instance = null;
    public static Replay.Services.GameLibrary instance {
        get {
            if (_instance == null) {
                _instance = new Replay.Services.GameLibrary ();
            }
            return _instance;
        }
    }

    // ROM path to game model mapping
    private Gee.Map<string, Replay.Models.Game> known_games = new Gee.HashMap<string, Replay.Models.Game> ();

    private GameLibrary () {
    }

    public void initialize () {
        // Load known ROMs from database
        // TODO
        // Check whether known ROMs can still be found on the filesystem
        // TODO
        // Check for bundled ROMs not already present in the database
        scan_rom_directory (GLib.File.new_for_path (Constants.ROM_DIR));
    }

    private void scan_rom_directory (GLib.File rom_directory) {
        if (!rom_directory.query_exists ()) {
            warning ("Bundled ROM directory not found: %s", rom_directory.get_path ());
            return;
        }
        GLib.FileEnumerator file_enumerator;
        try {
            file_enumerator = rom_directory.enumerate_children ("standard::*", GLib.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
        } catch (GLib.Error e) {
            warning ("Error while enumerating files in bundled ROM directory: %s", e.message);
            return;
        }
        GLib.FileInfo info;
        try {
            while ((info = file_enumerator.next_file ()) != null) {
                if (info.get_file_type () == GLib.FileType.DIRECTORY) {
                    continue;
                }
                // Can't make any assumptions about which file types are actually ROMs, but this is in the
                // bundled directory, so there *shouldn't* be anything else in there.
                found_rom (GLib.File.new_for_path (Constants.ROM_DIR + "/" + info.get_name ()));
            }
        } catch (GLib.Error e) {
            warning ("Error while iterating over files in bundled core directory: %s", e.message);
            return;
        }
    }

    private void found_rom (GLib.File rom_file) {
        //  if (!known_cores.has_key (core_info.core_name)) {
        //      debug ("Found bundled core %s for %s", core_info.core_name, core_info.system_name);
        //      // Store the core
        //      known_cores.set (core_info.core_name, new Replay.Models.LibretroCore () {
        //          path = core_file.get_path (),
        //          info = core_info
        //      });
        //      // Update the ROM extension map
        //      foreach (var extension in core_info.supported_extensions) {
        //          if (!rom_extensions.has_key (extension)) {
        //              rom_extensions.set (extension, new Gee.ArrayList<string> ());
        //          }
        //          rom_extensions.get (extension).add (core_info.core_name);
        //      }
        //  } else {
        //      warning ("Duplicate core files found for core name: %s, using first file found", core_info.core_name);
        //  }

        // TODO: Check if already in database
        //  bool is_new = false;
        //  debug ("Found bundled core: %s %s", core_info.core_name, is_new ? "(new)" : "");
        //  sql_client.insert_core (new Replay.Models.LibretroCore () {
        //      uri = core_file.get_uri (),
        //      info = core_info
        //  });
    }

}