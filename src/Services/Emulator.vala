/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.Emulator : GLib.Object {

    private const string SAVE_RAM_FILE_EXTENSION = "srm";
    private const string SAVE_STATE_FILE_EXTENSION = "state";

    public unowned Replay.Application application { get; construct; }

    private Replay.Windows.EmulatorWindow? window = null;
    private Replay.Models.LibretroCore? libretro_core = null;
    private Retro.Core? core = null;
    private Replay.Services.RetroInputManager? input_manager = null;
    private Replay.Models.Game? game = null;
    private GLib.File? rom = null;
    private GLib.Timer? timer = null;
    private GLib.Thread<void>? timer_thread = null;
    private GLib.Cancellable? timer_cancellable = null;

    private bool manually_paused = false;

    public Emulator (Replay.Application application) {
        Object (
            application: application
        );
    }

    //  public void load_rom (string uri) {
    //      var file = GLib.File.new_for_uri (uri);
    //      if (!GLib.File.new_for_uri (uri).query_exists ()) {
    //          critical ("ROM file not found: %s", uri);
    //          return;
    //      }
    //      rom = file;
    //  }

    public void load_game (Replay.Models.Game game) {
        var file = GLib.File.new_for_path (game.rom_path);
        if (!file.query_exists ()) {
            critical ("ROM file not found: %s", file.get_path ());
            return;
        }
        this.game = game;
        this.rom = file;
    }

    public void open () {
        if (window == null) {
            window = new Replay.Windows.EmulatorWindow (application, game.display_name);
            window.pause_button_clicked.connect (() => {
                manually_paused = true;
                pause ();
            });
            window.resume_button_clicked.connect (() => {
                manually_paused = false;
                resume ();
            });
            window.restart_button_clicked.connect (() => {
                save_memory ();
                stop ();
                start (libretro_core);
            });
            window.speed_changed.connect ((speed) => {
                core.set_speed_rate (speed);
            });
            window.focus_out_event.connect (() => {
                // Don't do anything if the emulator is already manually paused
                if (manually_paused) {
                    return false;
                }
                if (Replay.Application.settings.handle_window_focus_change) {
                    manually_paused = false;
                    window.show_resume_button ();
                    pause ();
                }
                return false;
            });
            window.focus_in_event.connect (() => {
                // Don't do anything if the emulator was manually paused
                if (manually_paused) {
                    return false;
                }
                if (Replay.Application.settings.handle_window_focus_change && !manually_paused) {
                    manually_paused = false;
                    window.show_pause_button ();
                    resume ();
                }
                return false;
            });
            window.destroy.connect (() => {
                save_memory ();
                stop ();
                close ();
            });
            opened ();
        }
    }

    public void close () {
        if (window != null) {
            window.close ();
            window = null;
            closed ();
        }
    }

    public void start (Replay.Models.LibretroCore? libretro_core) {
        if (window == null) {
            return;
        }
        if (core != null) {
            return;
        }
        this.libretro_core = libretro_core;
        Replay.Models.LibretroCore? core_model = libretro_core != null ? libretro_core : Replay.Core.Client.get_default ().core_repository.get_preferred_core_for_rom (rom);
        if (core_model == null) {
            // TODO: Display error to user
            critical ("No core found for ROM: %s", rom.get_path ());
            stop ();
            close ();
            return;
        }
        window.set_core_name (core_model.info.core_name);

        // Initialize the core and load memory and/or state
        core = new Retro.Core (core_model.path);
        core.set_save_directory (GLib.Environment.get_home_dir ()); // TODO: Change this (does it even work…?)
        core.set_medias ({ rom.get_uri () });
        try {
            debug ("Booting core %s…", core_model.info.core_name);
            core.boot ();
        } catch (GLib.Error e) {
            // TODO: Display error to user
            critical (e.message);
            stop ();
            close ();
            return;
        }
        load_memory ();

        // Set the view
        unowned Retro.CoreView view = window.get_core_view ();
        view.set_core (core);

        // Setup the device input
        input_manager = new Replay.Services.RetroInputManager (core, view);
        var active_device = input_manager.get_active_device ();
        window.update_input_device (active_device != null ? active_device.get_name () : "Keyboard");
        input_manager.device_connected.connect (on_device_connected);
        input_manager.device_disconnected.connect (on_device_disconnected);

        // Connect to core signals (should this be done prior to booting the core?)
        core.crashed.connect ((message) => {
            crashed (message);
        });
        core.notify["frames-per-second"].connect (() => {
            window.update_fps (core.frames_per_second);
        });

        core.set_speed_rate (Replay.Application.settings.emu_default_speed);

        // Run the game
        core.run ();

        // Update properties on the game
        game.is_played = true;
        game.last_played = new GLib.DateTime.now_local ();

        // Start the timer
        timer = new GLib.Timer ();
        timer_thread = new GLib.Thread<void> ("gameplay-timer", () => {
            while (!timer_cancellable.is_cancelled ()) {
                if (timer.is_active ()) {
                    game.time_played++;
                }
                Thread.usleep (1000000); // 1 second
            }
        });

        started ();
    }

    public void stop () {
        if (core != null) {
            timer.stop ();
            timer_cancellable.cancel ();
            core.stop ();
            core.reset ();
            core = null;
            stopped ();
        }
    }

    public void pause () {
        if (core != null) {
            debug ("Pausing…");
            timer.stop ();
            core.stop ();
            stopped ();
        }
    }

    public void resume () {
        if (core != null) {
            debug ("Resuming…");
            if (!timer.is_active ()) {
                timer.@continue ();
            }
            core.run ();
            resumed ();
        }
    }

    public void save_state () {
        if (core != null) {
            var state_file = get_state_file_for_rom (rom);
            debug ("Saving state to file: %s", state_file.get_path ());
            try {
                core.save_state (state_file.get_path ());
            } catch (GLib.Error e) {
                warning ("Error while saving state: %s", e.message);
            }
        }
    }

    /*
     * Savestates should be considered volatile and may not work correctly for certain games. This is a good feature
     * to have, but automatically reloading a savestate is NOT a good idea, as it may corrupt RAM when it is loaded.
     */
    public void load_state () {
        if (core != null) {
            var state_file = get_state_file_for_rom (rom);
            if (state_file.query_exists ()) {
                debug ("Loading state from file: %s", state_file.get_path ());
                try {
                    core.load_state (state_file.get_path ());
                } catch (GLib.Error e) {
                    warning ("Error while loading state: %s", e.message);
                }
            } else {
                debug ("No state file found");
            }
        }
    }

    // TODO: Check memory size via get_memory_size() before saving a file so we don't get 0B files
    public void save_memory () {
        if (core != null) {
            if (core.get_memory_size (Retro.MemoryType.SAVE_RAM) == 0) {
                debug ("Save RAM is 0B - skipping creation of save memory file");
                return;
            }
            var memory_file = get_memory_file_for_rom (rom);
            debug ("Saving memory to file: %s", memory_file.get_path ());
            try {
                core.save_memory (Retro.MemoryType.SAVE_RAM, memory_file.get_path ());
            } catch (GLib.Error e) {
                warning ("Error while saving memory: %s", e.message);
            }
        }
    }

    public void load_memory () {
        if (core != null && rom != null) {
            var memory_file = get_memory_file_for_rom (rom);
            if (memory_file.query_exists ()) {
                debug ("Loading save memory from file: %s", memory_file.get_path ());
                try {
                    core.load_memory (Retro.MemoryType.SAVE_RAM, memory_file.get_path ());
                } catch (GLib.Error e) {
                    warning ("Error while loading save memory: %s", e.message);
                }
            } else {
                debug ("No memory file found");
            }
        }
    }

    private void on_device_connected (Manette.Device device) {
        window.update_input_device (device.get_name ());
        window.notify_device_connected (device.get_name ());
    }

    private void on_device_disconnected (Manette.Device device) {
        // XXX: Currently only one input device is supported, so if a device was disconnected,
        // by default the new device must be the keyboard
        window.update_input_device ("Keyboard");
        window.notify_device_disconnected (device.get_name ());
    }

    // TODO: Need to handle the save files better for bundled games which will originate
    //       in the sandbox, but we probably want all save data to be outside the sandbox
    //       in the user's home directory.
    //
    //       Maybe always put the save files in the ROM directory regardless of where the
    //       ROM actually goes? Or add a new preference for a save file directory?

    private GLib.File get_memory_file_for_rom (GLib.File rom_file) {
        var rom_extension = Replay.Utils.FileUtils.get_extension (rom_file, false);
        var rom_filename = rom_file.get_basename ();
        var rom_directory = rom_file.get_parent ().get_path ();
        var memory_filename = rom_filename.substring (0, rom_filename.last_index_of (rom_extension, 0)) + SAVE_RAM_FILE_EXTENSION;
        return GLib.File.new_for_path ("%s/%s".printf (rom_directory, memory_filename));
    }

    private GLib.File get_state_file_for_rom (GLib.File rom_file) {
        var rom_extension = Replay.Utils.FileUtils.get_extension (rom_file, false);
        var rom_filename = rom_file.get_basename ();
        var rom_directory = rom_file.get_parent ().get_path ();
        var state_filename = rom_filename.substring (0, rom_filename.last_index_of (rom_extension, 0)) + SAVE_STATE_FILE_EXTENSION;
        return GLib.File.new_for_path ("%s/%s".printf (rom_directory, state_filename));
    }

    public signal void opened ();
    public signal void closed ();
    public signal void started ();
    public signal void paused ();
    public signal void resumed ();
    public signal void stopped ();
    public signal void crashed (string message);

}
