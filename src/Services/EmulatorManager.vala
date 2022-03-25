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

public class Replay.Services.EmulatorManager : GLib.Object {

    public unowned Replay.Application application { get; construct; }

    private Gee.List<Replay.Services.Emulator> emulators = new Gee.ArrayList<Replay.Services.Emulator> ();

    public EmulatorManager (Replay.Application application) {
        Object (
            application: application
        );
    }

    public void launch_game (string rom_uri) {
        // TODO: Validate rom_uri
        var emulator = new Replay.Services.Emulator (application);
        emulator.started.connect (on_emulator_started);
        emulator.closed.connect (on_emulator_closed);
        emulator.crashed.connect (on_emulator_crashed);
        emulator.load_rom (rom_uri);
        emulator.open ();
        emulator.start ();
        emulators.add (emulator);
    }

    private void on_emulator_started (Replay.Services.Emulator emulator) {
        debug ("Emulator started");
        emulators.add (emulator);
    }

    private void on_emulator_closed (Replay.Services.Emulator emulator) {
        debug ("Emulator closed");
        emulators.remove (emulator);
    }

    public void on_emulator_crashed (Replay.Services.Emulator emulator, string message) {
        // TODO: Display this to the user
        debug ("Emulator crashed: %s", message);
        emulators.remove (emulator);
    }

}
