/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Models.LibretroCoreInfo : GLib.Object {

    public string core_name { get; set; }
    public string display_name { get; set; }
    public string[] supported_extensions { get; set; }
    public string manufacturer { get; set; }
    public string? system_id { get; set; }
    public string? system_name { get; set; }
    public string license { get; set; }
    public string? display_version { get; set; }
    public string? description { get; set; }

    public LibretroCoreInfo.from_file (GLib.File file) {
        try {
            var input_stream = new GLib.DataInputStream (file.read ());
            string? line;
            while ((line = input_stream.read_line ()) != null) {
                // Ignore comments
                if (line.has_prefix ("#")) {
                    continue;
                }
                // Ignore empty lines
                if (line.length == 0) {
                    continue;
                }
                var delim_index = line.index_of ("=");
                var key = line.substring (0, delim_index).strip ();
                var value = line.substring (delim_index + 1).strip ();
                // Remove "" around string values
                value = value.has_prefix ("\"") ? value.substring (1) : value;
                value = value.has_suffix ("\"") ? value.substring (0, value.length - 1) : value;
                switch (key) {
                    case "display_name":
                        display_name = value;
                        break;
                    case "supported_extensions":
                        supported_extensions = value.split ("|");
                        break;
                    case "corename":
                        core_name = value;
                        break;
                    case "manufacturer":
                        manufacturer = value;
                        break;
                    case "systemid":
                        system_id = value;
                        break;
                    case "systemname":
                        system_name = value;
                        break;
                    case "license":
                        license = value;
                        break;
                    case "display_version":
                        display_version = value;
                        break;
                    case "description":
                        description = value;
                        break;
                    default:
                        //  warning ("Unhandled libretro core info file key: %s", key);
                        break;
                }
            }
        } catch (GLib.Error e) {
            critical ("Error reading libretro core info file (%s): %s", file.get_path (), e.message);
        }
    }

}
