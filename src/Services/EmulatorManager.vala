/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.EmulatorManager : GLib.Object {

    public unowned Replay.Application application { get; construct; }

    private Gee.List<Replay.Services.Emulator> emulators = new Gee.ArrayList<Replay.Services.Emulator> ();

    public EmulatorManager (Replay.Application application) {
        Object (
            application: application
        );
    }

    public void launch_game (Replay.Models.Game game, Replay.Models.LibretroCore? core) {
        // TODO: Validate rom_uri
        var emulator = new Replay.Services.Emulator (application);
        emulator.started.connect (on_emulator_started);
        emulator.closed.connect (on_emulator_closed);
        emulator.crashed.connect (on_emulator_crashed);
        emulator.load_game (game);
        emulator.open ();
        emulator.start (core);
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
