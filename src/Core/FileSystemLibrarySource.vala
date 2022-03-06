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

public class Replay.Core.FileSystemLibrarySource : Replay.Core.LibrarySource, GLib.Object {

    public string path { get; construct; }

    public FileSystemLibrarySource (string path) {
        Object (
            path: path
        );
    }

    public Gee.Collection<Replay.Models.Game> scan () {
        var games = new Gee.ArrayList<Replay.Models.Game> ();
        var directory = GLib.File.new_for_path (path);
        if (!directory.query_exists ()) {
            warning ("Library source directory not found: %s", directory.get_path ());
            return games;
        }
        GLib.FileEnumerator file_enumerator;
        try {
            file_enumerator = directory.enumerate_children ("standard::*", GLib.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
        } catch (GLib.Error e) {
            warning ("Error while enumerating files in library source directory: %s", e.message);
            return games;
        }
        GLib.FileInfo info;
        try {
            while ((info = file_enumerator.next_file ()) != null) {
                if (info.get_file_type () == GLib.FileType.DIRECTORY) {
                    continue;
                }
                // Can't make any assumptions about which file types are actually ROMs, but this is in the
                // bundled directory, so there *shouldn't* be anything else in there.
                //  on_rom_found (GLib.File.new_for_path (Constants.ROM_DIR + "/" + info.get_name ()));
                games.add (new Replay.Models.Game.from_file (GLib.File.new_for_path (path + "/" + info.get_name ())));
            }
        } catch (GLib.Error e) {
            warning ("Error while iterating over files in library source directory: %s", e.message);
            return games;
        }
        return games;
    }

}
