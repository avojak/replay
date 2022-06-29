/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

/**
 * Models details about a game as provided by the The Games DB.
 */
public class Replay.Models.TheGamesDBDetails : GLib.Object {

    public int64 id { get; set; }
    public string game_title { get; set; }
    public string? rating { get; set; }
    public string? overview { get; set; }

}
