/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Core.FileSystemLibrarySource : Replay.Core.LibrarySource, GLib.Object {

    public string path { get; construct; }

    public FileSystemLibrarySource (string path) {
        Object (
            path: path
        );
    }

    public Gee.Collection<Replay.Models.Game> scan () {
        debug ("Scanning library source %s", path);
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
                var file = GLib.File.new_for_path ("%s/%s".printf (path, info.get_name ()));
                // Only add games where the extension is declared to be supported by at least one core
                if (Replay.Core.Client.get_default ().core_repository.get_supported_extensions ().contains (Replay.Utils.FileUtils.get_extension (file))) {
                    games.add (new Replay.Models.Game.from_file (file));
                }
            }
        } catch (GLib.Error e) {
            warning ("Error while iterating over files in library source directory: %s", e.message);
            return games;
        }
        return games;
    }

}
