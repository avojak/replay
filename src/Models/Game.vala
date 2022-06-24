/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Models.Game : GLib.Object {

    public class MetadataDAO : GLib.Object {
        public int id { get; set; }
        public string rom_md5 { get; set; }
        public bool is_favorite { get; set; }
        public bool is_played { get; set; }
        public int64? last_played { get; set; }
        public int time_played { get; set; default = 0; }
    }

    public int id { get; set; }
    public string rom_path { get; set; }
    public string display_name { get; set; }
    public string? preferred_core_name { get; set; }
    //  public string? image_data { get; set; }
    public bool is_favorite { get; set; }
    public bool is_hidden { get; set; }
    public bool is_played { get; set; }
    public GLib.DateTime? last_played { get; set; }
    public int time_played { get; set; } // Time played in seconds
    public string? rom_md5 { get; set; }
    public Replay.Models.LibretroGameDetails? libretro_details { get; set; }

    public Game.from_file (GLib.File file) {
        Object (
            rom_path: file.get_path (),
            // Default display name is simply the name of the ROM without the file extension. If a proper
            // displayname is provided by Libretro in the database, that will be updated later.
            display_name: file.get_basename ().substring (0, file.get_basename ().last_index_of (".")),
            is_favorite: false,
            is_hidden: false,
            is_played: false,
            last_played: null,
            time_played: 0,
            rom_md5: Replay.Utils.DigestUtils.md5_for_file (file),
            libretro_details: null
        );
    }

}
