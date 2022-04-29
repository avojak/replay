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
 * Collection of utilities for computing the checksums of files.
 */
public class Replay.Utils.DigestUtils : GLib.Object {

    private const int BUFFER_SIZE = 256;

    /**
     * Computes the SHA256 checksum for the given file
     *
     * @param file for which to compute the checksum
     *
     * @return the checksum as a string, or null if there was an error
     */
    public static string? sha256_for_file (GLib.File file) {
        return checksum_for_file (file, GLib.ChecksumType.SHA256);
    }

    /**
     * Computes the MD5 checksum for the given file
     *
     * @param file for which to compute the checksum
     *
     * @return the checksum as a string, or null if there was an error
     */
    public static string? md5_for_file (GLib.File file) {
        return checksum_for_file (file, GLib.ChecksumType.MD5);
    }

    private static string? checksum_for_file (GLib.File file, GLib.ChecksumType checksum_type) {
        try {
            GLib.Checksum checksum = new GLib.Checksum (checksum_type);
            uint8 buffer[BUFFER_SIZE];
            size_t bytes_read;
            GLib.FileInputStream stream = file.read ();
            while ((bytes_read = stream.read (buffer)) > 0) {
                checksum.update (buffer, bytes_read);
            }
            return checksum.get_string ().up ();
        } catch (GLib.Error e) {
            warning ("Error while computing checksum for %s: %s", file.get_path (), e.message);
            return null;
        }
    }

}
