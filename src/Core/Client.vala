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

public class Replay.Core.Client : GLib.Object {

    private static GLib.Once<Replay.Core.Client> instance;
    public static unowned Replay.Core.Client get_default () {
        return instance.once (() => { return new Replay.Core.Client (); });
    }

    private Gee.List<Replay.Core.LibretroCoreSource> core_sources = new Gee.ArrayList<Replay.Core.LibretroCoreSource> ();
    private Gee.List<Replay.Core.LibrarySource> library_sources = new Gee.ArrayList<Replay.Core.LibrarySource> ();

    construct {
        // Add the default sources for bundled cores and ROMs
        core_sources.add (new Replay.Core.LibretroCoreSource (Constants.LIBRETRO_CORE_DIR));
        library_sources.add (new Replay.Core.LibrarySource (Constants.ROM_DIR));
    }

    public async void scan_all_sources () {
        yield scan_core_sources ();
        yield scan_library_sources ();
    }

    public async void scan_core_sources () {
        foreach (var core_source in core_sources) {
            core_source.scan ();
        }
        core_sources_scanned ();
    }

    public async void scan_library_sources () {
        foreach (var library_source in library_sources) {
            library_source.scan ();
        }
        library_sources_scanned ();
    }

    public signal void core_sources_scanned ();
    public signal void library_sources_scanned ();

}