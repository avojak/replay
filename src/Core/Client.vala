/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Core.Client : GLib.Object {

    private static GLib.Once<Replay.Core.Client> instance;
    public static unowned Replay.Core.Client get_default () {
        return instance.once (() => { return new Replay.Core.Client (); });
    }

    public Replay.Services.LibretroCoreRepository core_repository;
    public Replay.Services.LibretroGameRepository game_repository;
    public Replay.Services.LibretroGameArtRepository game_art_repository;
    public Replay.Services.TheGamesDBRepository the_games_db_repository;
    public Replay.Services.GameLibrary game_library;
    public Replay.Services.EmulatorManager emulator_manager;
    public Replay.Services.SQLClient sql_client;

    construct {
        core_repository = Replay.Services.LibretroCoreRepository.get_default ();
        game_repository = Replay.Services.LibretroGameRepository.get_default ();
        game_art_repository = Replay.Services.LibretroGameArtRepository.get_default ();
        the_games_db_repository = Replay.Services.TheGamesDBRepository.get_default ();
        game_library = Replay.Services.GameLibrary.get_default ();
        emulator_manager = new Replay.Services.EmulatorManager (Replay.Application.get_instance ());
        sql_client = Replay.Services.SQLClient.get_default ();

        // Add the default sources for bundled cores and ROMs
        core_repository.core_sources.add (new Replay.Core.FileSystemLibretroCoreSource (Constants.BUNDLED_LIBRETRO_CORE_DIR));
        core_repository.core_sources.add (new Replay.Core.FileSystemLibretroCoreSource (Constants.SYSTEM_LIBRETRO_CORE_DIR));
        game_library.library_sources.add (new Replay.Core.FileSystemLibrarySource (Constants.BUNDLED_ROM_DIR));

        // Lookup preference for user-specified ROM directory. If none specified (e.g. first launch), default to ~/Games/Replay/.
        // TODO: Seems like creating ~/Games/Replay won't be possible due to Flatpak sandbox?
        if (Replay.Application.settings.user_rom_directory.strip ().length == 0) {
            Replay.Application.settings.user_rom_directory = GLib.Environment.get_home_dir (); // "%s/Games/Replay".printf (GLib.Environment.get_home_dir ());
            Replay.Application.settings.user_save_directory = GLib.Environment.get_home_dir (); // Default this to the same location as the ROMs
        }
        game_library.library_sources.add (new Replay.Core.FileSystemLibrarySource (Replay.Application.settings.user_rom_directory));
    }

    public async Gee.Collection<Replay.Models.LibretroCore> scan_core_sources_async () {
        GLib.SourceFunc callback = scan_core_sources_async.callback;
        Gee.Collection<Replay.Models.LibretroCore> result = new Gee.ArrayList<Replay.Models.LibretroCore> ();

        new GLib.Thread<bool> ("scan-core-sources", () => {
            result = core_repository.reload_cores ();
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        return result;
    }

    public async Gee.Collection<Replay.Models.Game> scan_library_sources_async () {
        GLib.SourceFunc callback = scan_library_sources_async.callback;
        Gee.Collection<Replay.Models.Game> result = new Gee.ArrayList<Replay.Models.Game> ();

        new GLib.Thread<bool> ("scan-library-sources", () => {
            result = game_library.reload_games ();
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        return result;
    }

    public signal void core_sources_scanned (Gee.List<Replay.Models.LibretroCore> cores);
    public signal void library_sources_scanned (Gee.List<Replay.Models.Game> games);

}
