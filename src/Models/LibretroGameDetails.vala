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
