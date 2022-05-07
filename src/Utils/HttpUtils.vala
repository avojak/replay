/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

/**
 * Collection of utilities for performing HTTP operations.
 */
public class Replay.Utils.HttpUtils : GLib.Object {

    /**
     * Downloads the file at the given URL.
     *
     * @param url pointing to the file to download
     * @param file where the downloaded content will be saved
     */
    public static void download_file (string url, GLib.File file) throws GLib.Error {
        debug (url);
        var session = new Soup.Session ();
        var input_stream = new DataInputStream (session.send (new Soup.Message.from_uri ("GET", new Soup.URI (url)), null));
        var output_stream = file.replace (null, false, GLib.FileCreateFlags.NONE, null);
        size_t bytes_read;
        uint8[] buffer = new uint8[256];
        while ((bytes_read = input_stream.read (buffer, null)) != 0) {
            output_stream.write (buffer, null);
        }
    }

}
