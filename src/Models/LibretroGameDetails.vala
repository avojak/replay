/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

/**
 * Models details about a game as provided by the Libretro Retroarch database.
 */
public class Replay.Models.LibretroGameDetails : GLib.Object {

    public string? serial_id { get; set; }
    public int? release_year { get; set; }
    public int? release_month { get; set; }
    public string? display_name { get; set; }
    public string? description { get; set; }
    public string? developer_name { get; set; }
    public string? franchise_name { get; set; }
    public string? region_name { get; set; }
    public string? genre_name { get; set; }
    public string? rom_name { get; set; }
    public string rom_md5 { get; set; }
    public string? platform_name { get; set; }
    public string? manufacturer_name { get; set; }

}
