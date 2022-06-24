/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.LibretroCoreRepository : GLib.Object {

    private static GLib.Once<Replay.Services.LibretroCoreRepository> instance;
    public static unowned Replay.Services.LibretroCoreRepository get_default () {
        return instance.once (() => { return new Replay.Services.LibretroCoreRepository (); });
    }

    public Gee.List<Replay.Core.LibretroCoreSource> core_sources;

    // Map of cores by their core_name attribute
    private Gee.Map<string, Replay.Models.LibretroCore> known_cores;
    // Map of ROM extensions to the core_names that support them
    private Gee.Map<string, Gee.List<string>> rom_extensions;

    private LibretroCoreRepository () {
    }

    construct {
        core_sources = new Gee.ArrayList<Replay.Core.LibretroCoreSource> ();
        known_cores = new Gee.HashMap<string, Replay.Models.LibretroCore> ();
        rom_extensions = new Gee.HashMap<string, Gee.List<string>> ();
        // TODO: Might be useful to have a thread watching the core directory for changes?
    }

    /**
     * Re-scan the system sources for cores.
     */
    public Gee.Collection<Replay.Models.LibretroCore> reload_cores () {
        // Clear current known cores
        known_cores.clear ();
        rom_extensions.clear ();

        // Scan the system
        var cores = new Gee.HashMap<string, Replay.Models.LibretroCore> ();
        foreach (var core_source in core_sources) {
            foreach (var core in core_source.scan ()) {
                // Don't allow duplicates
                if (!cores.has_key (core.info.core_name)) {
                    debug ("Found core %s for %s", core.info.core_name, core.info.system_name);
                    cores.set (core.info.core_name, core);
                }
            }
        }

        // Set new collection of cores
        foreach (var core in cores.values) {
            known_cores.set (core.info.core_name, core);
            // Map ROM extensions to the cores that support it
            foreach (var extension in core.info.supported_extensions) {
                if (!rom_extensions.has_key (extension)) {
                    rom_extensions.set (extension, new Gee.ArrayList<string> ());
                }
                rom_extensions.get (extension).add (core.info.core_name);
            }
        }

        return cores.values;
    }

    public Replay.Models.LibretroCore? get_preferred_core_for_rom (GLib.File rom) {
        var extension = Replay.Utils.FileUtils.get_extension (rom);
        if (!rom_extensions.has_key (extension)) {
            return null;
        }
        // TODO: Check for preferences, etc. instead of just returning the first
        var core_name = rom_extensions.get (extension).get (0);
        return known_cores.get (core_name);
    }

    public Gee.Collection<Replay.Models.LibretroCore> get_cores_for_rom (GLib.File rom) {
        var extension = Replay.Utils.FileUtils.get_extension (rom);
        var cores = new Gee.ArrayList<Replay.Models.LibretroCore> ();
        if (!rom_extensions.has_key (extension)) {
            return cores;
        }
        foreach (var core_name in rom_extensions.get (extension)) {
            cores.add (known_cores.get (core_name));
        }
        return cores;
    }

    public Gee.Collection<Replay.Models.LibretroCore> get_cores () {
        return known_cores.values;
    }

    public Gee.Map<string, Gee.Collection<Replay.Models.LibretroCore>> get_cores_by_manufacturer () {
        var mapping = new Gee.TreeMap<string, Gee.Collection<Replay.Models.LibretroCore>> ((key_a, key_b) => {
            return key_a.ascii_casecmp (key_b);
        });
        foreach (var core in get_cores ()) {
            if (!mapping.has_key (core.info.manufacturer)) {
                mapping.set (core.info.manufacturer, new Gee.TreeSet<Replay.Models.LibretroCore> ((core_a, core_b) => {
                    return core_a.info.core_name.ascii_casecmp (core_b.info.core_name);
                }));
            }
            mapping.get (core.info.manufacturer).add (core);
        }
        return mapping;
    }

    public Gee.List<string> get_supported_extensions () {
        var extensions = new Gee.ArrayList<string> ();
        foreach (var entry in known_cores.entries) {
            foreach (var extension in entry.value.info.supported_extensions) {
                extensions.add (extension);
            }
        }
        return extensions;
    }

    public Replay.Models.LibretroCore? get_core_by_name (string core_name) {
        if (!known_cores.has_key (core_name)) {
            return null;
        }
        return known_cores.get (core_name);
    }

}
