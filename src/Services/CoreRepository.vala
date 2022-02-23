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

    // Map of cores by their core_name attribute
    private Gee.Map<string, Replay.Models.LibretroCore> known_cores = new Gee.HashMap<string, Replay.Models.LibretroCore> ();
    // Map of ROM extensions to the core_names that support them
    private Gee.Map<string, Gee.List<string>> rom_extensions = new Gee.HashMap<string, Gee.List<string>> ();

    construct {
        // TODO: Might be useful to have a thread watching the core directory for changes?
    }

    public void initialize () {
        // Do we even need to maintain core info in the database if the .info files are required anyway?
        // Preferred cores can be stored in the settings

        // Load known cores from the database
        // TODO
        // Check whether known cores can still be found on the filesystem
        // TODO
        // Check for bundled cores and descriptors that are not already present in the database

        scan_core_directory (GLib.File.new_for_path (Constants.LIBRETRO_CORE_DIR));
        // TODO: Scan user directory for user-provided cores (if name conflict, defer to user-provided)
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
                    on_core_found (core_file, info_file);
                }
            }
        } catch (GLib.Error e) {
            warning ("Error while iterating over files in bundled core directory: %s", e.message);
            return;
        }
    }

    private void on_core_found (GLib.File core_file, GLib.File info_file) {
        var core_info = new Replay.Models.LibretroCoreInfo.from_file (info_file);
        if (!known_cores.has_key (core_info.core_name)) {
            debug ("Found bundled core %s for %s", core_info.core_name, core_info.system_name);
            // Store the core
            var core = new Replay.Models.LibretroCore () {
                path = core_file.get_path (),
                info = core_info
            };
            known_cores.set (core_info.core_name, core);
            core_found (core);
            // Update the ROM extension map
            foreach (var extension in core_info.supported_extensions) {
                if (!rom_extensions.has_key (extension)) {
                    rom_extensions.set (extension, new Gee.ArrayList<string> ());
                }
                rom_extensions.get (extension).add (core_info.core_name);
            }
        } else {
            warning ("Duplicate core files found for core name: %s, using first file found", core_info.core_name);
        }

        // TODO: Check if already in database
        //  bool is_new = false;
        //  debug ("Found bundled core: %s %s", core_info.core_name, is_new ? "(new)" : "");
        //  sql_client.insert_core (new Replay.Models.LibretroCore () {
        //      uri = core_file.get_uri (),
        //      info = core_info
        //  });
    }

    public Replay.Models.LibretroCore? get_core_for_rom (GLib.File rom) {
        var extension = rom.get_path ().substring (rom.get_path ().last_index_of (".") + 1);
        if (!rom_extensions.has_key (extension)) {
            return null;
        }
        // TODO: Check for preferences, etc. instead of just returning the first
        var core_name = rom_extensions.get (extension).get (0);
        return known_cores.get (core_name);
    }

    public signal void core_found (Replay.Models.LibretroCore core);

}
