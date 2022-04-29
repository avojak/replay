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

/**
 * Collection of utilities for performing operations on files.
 */
public class Replay.Utils.FileUtils : GLib.Object {

    /**
     * Determines the extension for the given file.
     *
     * @param file for which to get the extension
     * @param normalize if the returned string should be normalized (i.e. case-converted down)
     *
     * @return the file extension string, or null if the file does not exist, or there is no file extension
     */
    public static string? get_extension (GLib.File file, bool normalize = true) {
        string? path = file.get_path ();
        if (path == null) {
            return null;
        }
        int last_separator = path.last_index_of (".");
        if (last_separator == -1) {
            return null;
        }
        var extension = path.substring (last_separator + 1);
        return normalize ? extension.down () : extension;
    }

}
