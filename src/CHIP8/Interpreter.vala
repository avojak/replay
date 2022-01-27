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

public class Replay.CHIP8.Interpreter : Replay.Emulator, GLib.Object {

    public const string HARDWARE_NAME = "CHIP-8";
    public const string COMMON_NAME = "CHIP-8";

    private Thread<int>? emulator_thread;
    private Cancellable? cancellable;

    private Replay.CHIP8.Memory.MMU mmu;
    private Replay.CHIP8.Processor.CPU cpu;
    //  private Replay.CHIP8.Graphics.PPU ppu;
    private Replay.CHIP8.Graphics.Display display;

    construct {
        mmu = new Replay.CHIP8.Memory.MMU ();
        cpu = new Replay.CHIP8.Processor.CPU (mmu);
        cpu.draw_pixel.connect ((x, y, pixel) => {
            display.set_pixel (x, y, pixel);
        });
        //  ppu = new Replay.CHIP8.Graphics.PPU ();

        initialize ();
    }

    private void initialize () {
        //  cpu.initialize_registers ();
        //  mmu.initialize_io_registers ();
        //  mmu.load_boot_rom ();
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
        debug (@"Starting $COMMON_NAME emulator…");
        while (true) {
            // TODO: Do the stuff
            if (cancellable.is_cancelled ()) {
                break;
            }
            tick ();
        }
        return 0;
    }

    private void tick () {
        cpu.tick ();
    }

    public void stop () {
        debug (@"Stopping $COMMON_NAME emulator…");
        cancellable.cancel ();
        emulator_thread = null;
    }

    public void show (Replay.MainWindow main_window) {
        if (display == null) {
            display = new Replay.CHIP8.Graphics.Display (main_window);
            display.show_all ();
            display.destroy.connect (() => {
                display = null;
                stop ();
                closed ();
            });
        }
        display.present ();
    }

    public void hide () {
        if (display != null) {
            display.close ();
        }
    }

}
