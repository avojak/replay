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

public class Replay.Services.CoreManager : GLib.Object {

    // The directory containing cores bundled with the app
    private const string BUNDLED_CORE_DIR = "/app/share/libretro/cores";

    construct {

    }

    public Retro.Core get_for_extension (string extension) {
        //  return new Retro.Core ("/app/share/libretro/cores/meteor_libretro.so");
        return new Retro.Core ("/app/share/libretro/cores/gearboy_libretro.so");
    }

}