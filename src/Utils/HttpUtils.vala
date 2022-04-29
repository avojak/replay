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

public class Replay.Utils.HttpUtils : GLib.Object {

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
