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

public class Replay.Services.Emulator : GLib.Object {

    public unowned Replay.Application application { get; construct; }

    private Replay.Windows.EmulatorWindow? window = null;
    private Retro.Core? core = null;
    private GLib.File? rom = null;

    public Emulator (Replay.Application application) {
        Object (
            application: application
        );
    }

    public void load_rom (string uri) {
        var file = GLib.File.new_for_uri (uri);
        if (!GLib.File.new_for_uri (uri).query_exists ()) {
            critical ("ROM file not found: %s", uri);
            return;
        }
        rom = file;
    }

    public void open () {
        if (window == null) {
            window = new Replay.Windows.EmulatorWindow (application);
            window.pause_button_clicked.connect (pause);
            window.resume_button_clicked.connect (resume);
            window.destroy.connect (() => {
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

    public void start () {
        if (window == null) {
            return;
        }
        if (core != null) {
            return;
        }
        Replay.Models.LibretroCore? core_model = Replay.Application.core_repository.get_core_for_rom (rom);
        if (core_model == null) {
            // TODO: Display error to user
            critical ("No core found for ROM: %s", rom.get_path ());
            stop ();
            close ();
            return;
        }
        core = new Retro.Core (core_model.path);
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
        unowned Retro.CoreView view = window.get_core_view ();
        view.set_core (core);
        view.set_as_default_controller (core);
        core.set_keyboard (view);
        core.run ();
        started ();
    }

    public void stop () {
        if (core != null) {
            core.stop ();
            core.reset ();
            core = null;
            stopped ();
        }
    }

    public void pause () {
        if (core != null) {
            debug ("Pausing…");
            core.stop ();
            stopped ();
        }
    }

    public void resume () {
        if (core != null) {
            debug ("Resuming…");
            core.run ();
            resumed ();
        }
    }

    public signal void opened ();
    public signal void closed ();
    public signal void started ();
    public signal void paused ();
    public signal void resumed ();
    public signal void stopped ();

}
