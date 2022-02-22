/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Replay.Models.System : GLib.Object {

    /*
     * Libretro .info files for cores do not provide an adequate way, by themselves, to support
     * mapping a singular ROM file extension back to a single system. This is primarily for
     * user-friendliness, because we want to show a user that a .gbc ROM corresponds to a
     * Nintendo Game Boy Color, and behind the scenes we can load a core that runs the game.
     * We don't want to necessarily lump all Game Boy/Game Boy Color/Game Boy Advance games
     * into the same category in the UI.
     *
     * Unless the user has manually specified a particular core preference for a game, the
     * decision for which core is running should be transparent.
     *
     * Obviously this approach has limitations. If a user installs a core that doesn't correspond
     * to any system known here, we won't be able to easily group ROMs for that core. In this
     * case, we may need to visually show an "Other" category.
     *
     * TODO: This may fall apart for later systems (e.g. PlayStation) where there isn't a
     * defining file extension. We might need a better method, or default to "Other" and let
     * the user classify appropriately?
     */

    public static Replay.Models.System CHIP8 = new Replay.Models.System ("chip_8", "CHIP-8", "Joseph Weisbecker", { "ch8" });

    public static Replay.Models.System GAME_BOY = new Replay.Models.System ("game_boy", "Game Boy", "Nintendo", { "gb" });
    public static Replay.Models.System GAME_BOY_COLOR = new Replay.Models.System ("game_boy_color", "Game Boy Color", "Nintendo", { "gbc" });
    public static Replay.Models.System GAME_BOY_ADVANCE = new Replay.Models.System ("game_boy_advance", "Game Boy Advance", "Nintendo", { "gba" });

    public static Replay.Models.System NINTENDO_ENTERTAINMENT_SYSTEM = new Replay.Models.System ("nes", "Nintendo Entertainment System", "Nintendo", { "nes" });
    //  public static Replay.Models.System NINTENDO_FAMICOM = new Replay.Models.System ("fds", "Family Computer Disk System", "Nintendo", { "fds" });
    public static Replay.Models.System SUPER_NINTENDO_ENTERTAINMENT_SYSTEM = new Replay.Models.System ("super_nes", "Super Nintendo Entertainment System", "Nintendo", { "sfc" });

    public static Replay.Models.System NINTENDO_64 = new Replay.Models.System ("nintendo_64", "Nintendo 64", "Nintendo", { "n64" });

    public static Replay.Models.System SATURN = new Replay.Models.System ("sega_saturn", "Sega Saturn", "Sega", { /* TODO */ });
    public static Replay.Models.System SEGA_MASTER_SYSTEM = new Replay.Models.System ("master_system", "Sega Master System", "Sega", { "sms" });

    public static Replay.Models.System PLAYSTATION = new Replay.Models.System ("playstation", "PlayStation", "Sony", { /* TODO */ });
    public static Replay.Models.System PLAYSTATION_2 = new Replay.Models.System ("playstation2", "PlayStation 2", "Sony", { /* TODO */ });
    public static Replay.Models.System PLAYSTATION_PORTABLE = new Replay.Models.System ("playstation_portable", "PlayStation Portable", "Sony", { /* TODO */ });

    public string id { get; } // Corresponds to a libretro system_id
    public string display_name { get; }
    public string manufacturer { get; }
    public string[] extensions { get; }

    private System (string id, string display_name, string manufacturer, string[] extensions) {
        Object (
            id: id,
            display_name: display_name,
            manufacturer: manufacturer,
            extensions: extensions
        );
    }

}