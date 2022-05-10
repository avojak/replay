/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

/**
 * Collection of utilities for performing HTTP operations.
 */
public class Replay.Utils.HttpUtils : GLib.Object {

    private const int BUFFER_SIZE = 256;

    /**
     * Downloads the file at the given URL.
     *
     * @param url pointing to the file to download
     * @param file where the downloaded content will be saved
     */
    public static void download_file (string url, GLib.File file, GLib.Cancellable? cancellable = null) throws GLib.Error {
        var session = new Soup.Session ();
        var input_stream = new DataInputStream (session.send (new Soup.Message.from_uri ("GET", new Soup.URI (url)), cancellable));
        var output_stream = file.replace (null, false, GLib.FileCreateFlags.NONE, cancellable);
        GLib.Bytes bytes;
        while ((bytes = input_stream.read_bytes (BUFFER_SIZE, cancellable)).length > 0) {
            output_stream.write_bytes (bytes, cancellable);
        }
    }

}
