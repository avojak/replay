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
    public Replay.Services.GameLibrary game_library;
    public Replay.Services.EmulatorManager emulator_manager;
    public Replay.Services.SQLClient sql_client;

    private Gee.List<Replay.Core.LibretroCoreSource> core_sources = new Gee.ArrayList<Replay.Core.LibretroCoreSource> ();
    private Gee.List<Replay.Core.LibrarySource> library_sources = new Gee.ArrayList<Replay.Core.LibrarySource> ();

    construct {
        core_repository = Replay.Services.LibretroCoreRepository.get_default ();
        game_repository = Replay.Services.LibretroGameRepository.get_default ();
        game_art_repository = Replay.Services.LibretroGameArtRepository.get_default ();
        game_library = Replay.Services.GameLibrary.get_default ();
        emulator_manager = new Replay.Services.EmulatorManager (Replay.Application.get_instance ());
        sql_client = Replay.Services.SQLClient.get_default ();

        // Add the default sources for bundled cores and ROMs
        core_sources.add (new Replay.Core.FileSystemLibretroCoreSource (Constants.BUNDLED_LIBRETRO_CORE_DIR));
        core_sources.add (new Replay.Core.FileSystemLibretroCoreSource (Constants.SYSTEM_LIBRETRO_CORE_DIR));
        library_sources.add (new Replay.Core.FileSystemLibrarySource (Constants.BUNDLED_ROM_DIR));

        // Lookup preference for user-specified ROM directory. If none specified (e.g. first launch), default to ~/Games/Replay/.
        // TODO: Seems like creating ~/Games/Replay won't be possible due to Flatpak sandbox?
        if (Replay.Application.settings.user_rom_directory.strip ().length == 0) {
            Replay.Application.settings.user_rom_directory = GLib.Environment.get_home_dir (); // "%s/Games/Replay".printf (GLib.Environment.get_home_dir ());
            Replay.Application.settings.user_save_directory = GLib.Environment.get_home_dir (); // Default this to the same location as the ROMs
            //  var user_rom_dir_file = GLib.File.new_for_path (user_rom_dir);
            //  if (!user_rom_dir_file.query_exists ()) {
            //      try {
            //          if (!user_rom_dir_file.make_directory_with_parents ()) {
            //              warning ("Did not create user rom directory (%s)", user_rom_dir);
            //          }
            //      } catch (GLib.Error e) {
            //          warning ("Error while creating user rom directory (%s): %s", user_rom_dir, e.message);
            //      }
            //  }
        }
        library_sources.add (new Replay.Core.FileSystemLibrarySource (Replay.Application.settings.user_rom_directory));
    }

    //  public async void scan_all_sources () {
    //      yield scan_core_sources ();
    //      yield scan_library_sources ();
    //  }

    public async Gee.Collection<Replay.Models.LibretroCore> scan_core_sources () {
        GLib.SourceFunc callback = scan_core_sources.callback;
        var result = new Gee.HashMap<string, Replay.Models.LibretroCore> ();

        new GLib.Thread<bool> ("scan-core-sources", () => {
            var cores = new Gee.HashMap<string, Replay.Models.LibretroCore> ();
            foreach (var core_source in core_sources) {
                foreach (var core in core_source.scan ()) {
                    if (!cores.has_key (core.info.core_name)) {
                        cores.set (core.info.core_name, core);
                    }
                }
            }
            result = cores;
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        foreach (var core in result.values) {
            debug ("Found core %s for %s", core.info.core_name, core.info.system_name);
        }
        // TODO: Store stuff in database if necessary
        core_repository.set_cores (result.values);
        return result.values;
        //  core_sources_scanned (cores);
    }

    public async Gee.List<Replay.Models.Game> scan_library_sources () {
        GLib.SourceFunc callback = scan_library_sources.callback;
        var result = new Gee.ArrayList<Replay.Models.Game> ();

        new GLib.Thread<bool> ("scan-library-sources", () => {
            var games = new Gee.ArrayList<Replay.Models.Game> ();
            foreach (var library_source in library_sources) {
                games.add_all (library_source.scan ());
            }
            // Lookup the game in the Libretro database
            foreach (var game in games) {
                var game_details = game_repository.lookup_for_md5 (game.rom_md5);
                if (game_details.size == 0) {
                    debug ("No LibretroDB entry found for %s (MD5: %s)", game.display_name, game.rom_md5);
                    continue;
                }
                if (game_details.size > 1) {
                    debug ("Multiple LibretroDB entries found for %s, using first entry", game.display_name);
                }
                game.libretro_details = game_details.get (0);
                if (game.libretro_details.display_name != null) {
                    game.display_name = game.libretro_details.display_name;
                }
            }
            // Lookup the game in the Replay database
            foreach (var game in games) {
                // If the game is already known in the database, fetch the metadata. If not, add it.
                Replay.Models.Game.MetadataDAO? metadata = sql_client.get_game (game.rom_md5);
                if (metadata != null) {
                    game.is_favorite = metadata.is_favorite;
                    game.is_played = metadata.is_played;
                    game.last_played = metadata.last_played == null ? null : new GLib.DateTime.from_unix_local (metadata.last_played);
                } else {
                    sql_client.insert_game (game);
                }
            }
            // TODO: Maybe do this somewhere else since it could take an even longer time?
            foreach (var game in games) {
                game_art_repository.download_box_art (game);
                game_art_repository.download_screenshot_art (game);
                game_art_repository.download_titlescreen_art (game);
            }
            result = games;
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        foreach (var game in result) {
            debug ("Found game %s (MD5: %s)", game.display_name, game.rom_md5);
        }
        // TODO: Store stuff in database if necessary
        game_library.set_games (result);
        return result;
        //  library_sources_scanned (games);
    }

    public signal void core_sources_scanned (Gee.List<Replay.Models.LibretroCore> cores);
    public signal void library_sources_scanned (Gee.List<Replay.Models.Game> games);

}
