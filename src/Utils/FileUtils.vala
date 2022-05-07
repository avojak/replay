/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
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
