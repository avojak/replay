/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.GameLibrary : GLib.Object {

    private static GLib.Once<Replay.Services.GameLibrary> instance;
    public static unowned Replay.Services.GameLibrary get_default () {
        return instance.once (() => { return new Replay.Services.GameLibrary (); });
    }

    public Gee.List<Replay.Core.LibrarySource> library_sources;

    // ROM path to game model mapping
    private Gee.Map<string, Replay.Models.Game> known_games = new Gee.HashMap<string, Replay.Models.Game> ();

    private GameLibrary () {
    }

    construct {
        library_sources = new Gee.ArrayList<Replay.Core.LibrarySource> ();
    }

    /**
     * Set the games in the library after scanning sources.
     */
    public void set_games (Gee.List<Replay.Models.Game> games) {
        known_games.clear ();
        foreach (var game in games) {
            if (!known_games.has_key (game.rom_path)) {
                known_games.set (game.rom_path, game);
            }
        }
    }

    public Gee.Collection<Replay.Models.Game> reload_games () {
        // Clear previously known games
        known_games.clear ();

        // De-deuplicate by mapping ROM MD5 to game model
        var rom_checksums = new Gee.ArrayList<string> ();
        foreach (var library_source in library_sources) {
            foreach (var game in library_source.scan ()) {
                if (!rom_checksums.contains (game.rom_md5)) {
                    // Lookup the game in the Libretro database
                    var game_details = Replay.Core.Client.get_default ().game_repository.lookup_for_md5 (game.rom_md5);
                    if (game_details.size == 0) {
                        debug ("No LibretroDB entry found for %s (MD5: %s)", game.display_name, game.rom_md5);
                    } else {
                        if (game_details.size > 1) {
                            debug ("Multiple LibretroDB entries found for %s, using first entry", game.display_name);
                        }
                        game.libretro_details = game_details.get (0);
                        // Check if the Libretro database contains a better display name than defaulting to the name of the ROM file
                        if (game.libretro_details.display_name != null) {
                            game.display_name = game.libretro_details.display_name;
                        }
                    }

                    // If the game is already known in the Replay database, fetch the metadata. If not, add it.
                    Replay.Models.Game.MetadataDAO? metadata = Replay.Core.Client.get_default ().sql_client.get_game (game.rom_md5);
                    if (metadata != null) {
                        game.is_favorite = metadata.is_favorite;
                        game.is_played = metadata.is_played;
                        game.last_played = metadata.last_played == null ? null : new GLib.DateTime.from_unix_local (metadata.last_played);
                        game.time_played = metadata.time_played;
                    } else {
                        Replay.Core.Client.get_default ().sql_client.insert_game (game);
                    }

                    debug ("Found game %s (MD5: %s)", game.display_name, game.rom_md5);
                    rom_checksums.add (game.rom_md5);

                    // Store the game internally by the ROM path, even though we deconflict based on MD5. If two ROMs
                    // have the same path, then they will naturally have the same MD5 (pointing to same file), but if
                    // two ROMs have the same MD5, they may not have the same path (duplicates in different folders).
                    known_games.set (game.rom_path, game);
                }
            }
        }

        // TODO: Maybe do this somewhere else since it could take an even longer time?
        foreach (var game in known_games.values) {
            Replay.Core.Client.get_default ().game_art_repository.download_box_art (game);
            Replay.Core.Client.get_default ().game_art_repository.download_screenshot_art (game);
            Replay.Core.Client.get_default ().game_art_repository.download_titlescreen_art (game);
        }

        return known_games.values;
    }

    public Gee.Collection<Replay.Models.Game> get_games () {
        return known_games.values;
    }

    public void set_game_played (Replay.Models.Game game, bool played) {
        known_games.get (game.rom_path).is_played = played;
        if (!played) {
            known_games.get (game.rom_path).last_played = null;
        }
        // Persist the update
        Replay.Core.Client.get_default ().sql_client.update_game (known_games.get (game.rom_path));
    }

    public void set_game_favorite (Replay.Models.Game game, bool favorite) {
        known_games.get (game.rom_path).is_favorite = favorite;
        // Persist the update
        Replay.Core.Client.get_default ().sql_client.update_game (known_games.get (game.rom_path));
    }

    public void update_last_run_date (Replay.Models.Game game) {
        known_games.get (game.rom_path).last_played = new GLib.DateTime.now_utc ();
        // Persist the update
        Replay.Core.Client.get_default ().sql_client.update_game (known_games.get (game.rom_path));
    }

    public void update_time_played (Replay.Models.Game game, int time_played_seconds) {
        known_games.get (game.rom_path).time_played = time_played_seconds;
        // Persist the update
        Replay.Core.Client.get_default ().sql_client.update_game (known_games.get (game.rom_path));
    }

}
