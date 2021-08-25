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

public class Replay.DMG.Emulator : GLib.Object {

    private const string HARDWARE_NAME = "DMG";
    private const string COMMON_NAME = "Game Boy";

    private Thread<int>? emulator_thread;
    private Cancellable? cancellable;

    private Replay.DMG.Memory.MMU mmu;
    private Replay.DMG.Processor.CPU cpu;

    construct {
        mmu = new Replay.DMG.Memory.MMU ();
        cpu = new Replay.DMG.Processor.CPU (mmu);

        initialize ();
    }

    private void initialize () {
        cpu.initialize_registers ();
        mmu.initialize_io_registers ();
    }

    public void start () {
        if (emulator_thread != null) {
            warning (@"$COMMON_NAME emulator is already running");
            return;
        }
        cancellable = new Cancellable ();
        emulator_thread = new Thread<int> (@"$HARDWARE_NAME emulator", do_run);
    }

    private int do_run () {
        debug (@"Starting $COMMON_NAME emulator...");
        while (true) {
            // TODO: Do the stuff
            if (cancellable.is_cancelled ()) {
                break;
            }
        }
        return 0;
    }

    private void tick () {
        cpu.execute_instruction ();
    }

    public void stop () {
        debug (@"Stopping $COMMON_NAME emulator...");
        cancellable.cancel ();
        emulator_thread = null;
    }

}
