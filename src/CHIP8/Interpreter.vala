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

    private const int BUFFER_SIZE = 512;

    private Thread<int>? emulator_thread;
    private Cancellable? cancellable;

    private Replay.CHIP8.Memory.MMU mmu;
    private Replay.CHIP8.Processor.CPU cpu;
    private Replay.CHIP8.Graphics.PPU ppu;
    private Replay.CHIP8.Graphics.Widgets.Display display;

    private Replay.CHIP8.Debug.Dialog debugger;

    construct {
        mmu = new Replay.CHIP8.Memory.MMU ();
        ppu = new Replay.CHIP8.Graphics.PPU (mmu);
        cpu = new Replay.CHIP8.Processor.CPU (mmu, ppu);

        initialize ();
    }

    private void initialize () {
        //  cpu.initialize_registers ();
        //  mmu.initialize_io_registers ();
        //  mmu.load_boot_rom ();
    }

    public void load_rom (GLib.File file) {
        if (!file.query_exists ()) {
            warning ("File not found: %s", file.get_path ());
            return;
        }
        try {
            GLib.FileInfo info = file.query_info("*", FileQueryInfoFlags.NONE);
            info.get_size ();
            // TODO: Validate ROM size against max size
        } catch (GLib.Error e) {
            warning ("Error querying ROM file info: %s", e.message);
        }
        try {
            ssize_t bytes_read = 0; // Total bytes read
            ssize_t buffer_bytes = 0; // Bytes read into the buffer
            uint8[] buffer = new uint8[BUFFER_SIZE];
            GLib.FileInputStream input_stream = file.read ();
            while ((buffer_bytes = input_stream.read (buffer, cancellable)) != 0) {
                for (int i = 0; i < buffer_bytes; i++) {
                    mmu.set_byte (Replay.CHIP8.Memory.MMU.ROM_OFFSET + (int) bytes_read + i, buffer[i]);
                }
                bytes_read += buffer_bytes;
            }
        } catch (GLib.Error e) {
            critical ("Error loading ROM file (%s): %s", file.get_path (), e.message);
            // TODO: Show error
        }
    }

    public void start () {
        if (emulator_thread != null) {
            warning (@"$COMMON_NAME interpreter is already running");
            return;
        }
        cancellable = new Cancellable ();
        emulator_thread = new Thread<int> (@"$HARDWARE_NAME interpreter", do_run);
    }

    private int do_run () {
        debug (@"Starting $COMMON_NAME interpreter…");
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
        //  debugger.update ();
        cpu.tick ();
    }

    public void stop () {
        debug (@"Stopping $COMMON_NAME interpreter…");
        cancellable.cancel ();
        emulator_thread = null;
    }

    public void show (Replay.MainWindow main_window) {
        if (display == null) {
            display = new Replay.CHIP8.Graphics.Widgets.Display (main_window, ppu);
            display.show_all ();
            display.destroy.connect (() => {
                display = null;
                debugger = null;
                stop ();
                closed ();
            });
            //  debugger = new Replay.CHIP8.Debug.Dialog (display);
            //  debugger.show_all ();
            //  debugger.present ();
        }
        display.present ();
    }

    public void hide () {
        if (display != null) {
            display.close ();
        }
    }

}
