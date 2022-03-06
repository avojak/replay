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

public class Replay.Core.FileSystemLibretroCoreSource : Replay.Core.LibretroCoreSource, GLib.Object {

    public string path { get; construct; }

    public FileSystemLibretroCoreSource (string path) {
        Object (
            path: path
        );
    }

    public Gee.Collection<Replay.Models.LibretroCore> scan () {
        var cores = new Gee.HashMap<string, Replay.Models.LibretroCore> ();
        var directory = GLib.File.new_for_path (path);
        if (!directory.query_exists ()) {
            warning ("Libretro core source directory not found: %s", directory.get_path ());
            return cores.values;
        }
        GLib.FileEnumerator file_enumerator;
        try {
            file_enumerator = directory.enumerate_children ("standard::*", GLib.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
        } catch (GLib.Error e) {
            warning ("Error while enumerating files in Libretro core source directory: %s", e.message);
            return cores.values;
        }
        GLib.FileInfo info;
        try {
            while ((info = file_enumerator.next_file ()) != null) {
                if (info.get_file_type () == GLib.FileType.DIRECTORY) {
                    continue;
                }
                var core_filename = "%s/%s".printf (path, info.get_name ());
                var core_file = GLib.File.new_for_path (core_filename);
                if (core_file.get_path ().has_suffix (".so")) {
                    // First look for the .info file in the same directory
                    var info_file = GLib.File.new_for_path (core_filename.replace (".so", ".info"));
                    if (info_file.query_exists ()) {
                        var core = create_core (core_file, info_file);
                        if (!cores.has_key (core.info.core_name)) {
                            cores.set (core.info.core_name, core);
                        }
                        continue;
                    }
                    // Next, check for any .info files installed with the libretro-core-info package
                    info_file = GLib.File.new_for_path ("%s/%s".printf (Constants.SYSTEM_LIBRETRO_INFO_DIR, info_file.get_basename ()));
                    if (info_file.query_exists ()) {
                        var core = create_core (core_file, info_file);
                        if (!cores.has_key (core.info.core_name)) {
                            cores.set (core.info.core_name, core);
                        }
                        continue;
                    }
                    warning ("Found Libretro core without corresponding .info file: %s", core_file.get_path ());
                }
            }
        } catch (GLib.Error e) {
            warning ("Error while iterating over files in Libretro core source directory: %s", e.message);
            return cores.values;
        }
        return cores.values;
    }

    private Replay.Models.LibretroCore create_core (GLib.File core_file, GLib.File info_file) {
        return new Replay.Models.LibretroCore () {
            path = core_file.get_path (),
            info = new Replay.Models.LibretroCoreInfo.from_file (info_file)
        };
    }

}
