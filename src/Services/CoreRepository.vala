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

public class Replay.Services.CoreRepository : GLib.Object {

    private static Replay.Services.CoreRepository _instance = null;
    public static Replay.Services.CoreRepository instance {
        get {
            if (_instance == null) {
                _instance = new Replay.Services.CoreRepository ();
            }
            return _instance;
        }
    }

    public Replay.Services.SQLClient sql_client { get; set; }

    public void initialize () {
        // Load known cores from the database
        // TODO
        // Check whether known cores can still be found on the filesystem
        // TODO
        // Check for bundled cores and descriptors that are not already present in the database
        scan_core_directory (GLib.File.new_for_path (Constants.LIBRETRO_CORE_DIR));
    }

    private void scan_core_directory (GLib.File core_directory) {
        if (!core_directory.query_exists ()) {
            warning ("Bundled core directory not found: %s", core_directory.get_path ());
            return;
        }
        GLib.FileEnumerator file_enumerator;
        try {
            file_enumerator = core_directory.enumerate_children ("standard::*", GLib.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
        } catch (GLib.Error e) {
            warning ("Error while enumerating files in bundled core directory: %s", e.message);
            return;
        }
        GLib.FileInfo info;
        try {
            while ((info = file_enumerator.next_file ()) != null) {
                if (info.get_file_type () == GLib.FileType.DIRECTORY) {
                    continue;
                }
                var core_file = GLib.File.new_for_path (Constants.LIBRETRO_CORE_DIR + "/" + info.get_name ());
                if (core_file.get_path ().has_suffix (".so")) {
                    var info_file = GLib.File.new_for_path (Constants.LIBRETRO_CORE_DIR + "/" + info.get_name ().replace (".so", ".info"));
                    if (!info_file.query_exists ()) {
                        warning ("Found bundled core without corresponding .info file: %s", core_file.get_path ());
                        continue;
                    }
                    found_core (core_file, info_file);
                }
            }
        } catch (GLib.Error e) {
            warning ("Error while iterating over files in bundled core directory: %s", e.message);
            return;
        }
    }

    private void found_core (GLib.File core_file, GLib.File info_file) {
        var core_info = new Replay.Models.LibretroCoreInfo.from_file (info_file);
        // TODO: Check if already in database
        bool is_new = false;
        debug ("Found bundled core: %s %s", core_info.core_name, is_new ? "(new)" : "");
        sql_client.insert_core (new Replay.Models.LibretroCore () {
            uri = core_file.get_uri (),
            info = core_info
        });
    }

}