/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
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

public class Replay.Services.LibretroGameRepository : GLib.Object {

    private static GLib.Once<Replay.Services.LibretroGameRepository> instance;
    public static unowned Replay.Services.LibretroGameRepository get_default () {
        return instance.once (() => { return new Replay.Services.LibretroGameRepository (); });
    }

    private const string DATABASE_FILE = "libretrodb.sqlite";

    private Sqlite.Database database;

    private LibretroGameRepository () {
        info ("Database file: %s", Constants.LIBRETRODB_DIR + "/" + DATABASE_FILE);
        initialize_database ();
    }

    private void initialize_database () {
        var db_file = Constants.LIBRETRODB_DIR + "/" + DATABASE_FILE;
        if (Sqlite.Database.open_v2 (db_file, out database) != Sqlite.OK) {
            // TODO: Show error message?
            critical ("Can't open database: %d: %s", database.errcode (), database.errmsg ());
            return;
        }
    }

    // TODO: This should probably lookup all the games we want at once, rather than making multiple DB calls
    public Gee.List<Replay.Models.LibretroGameDetails> lookup_for_md5 (string rom_md5) {
        var games = new Gee.ArrayList<Replay.Models.LibretroGameDetails> ();

        var sql = """
            SELECT games.serial_id,
                games.release_year,
                games.release_month,
                games.display_name,
                games.description,
                developers.name as developer_name,
                franchises.name as franchise_name,
                regions.name as region_name,
                genres.name as genre_name,
                roms.name as rom_name,
                roms.md5 as rom_md5,
                platforms.name as platform_name,
                manufacturers.name as manufacturer_name
            FROM games
                LEFT JOIN developers ON games.developer_id = developers.id
                LEFT JOIN franchises ON games.franchise_id = franchises.id
                LEFT JOIN genres ON games.genre_id = genres.id
                LEFT JOIN platforms ON games.platform_id = platforms.id
                    LEFT JOIN manufacturers ON platforms.manufacturer_id = manufacturers.id
                LEFT JOIN regions ON games.region_id = regions.id
                INNER JOIN roms ON games.rom_id = roms.id
            WHERE roms.md5 = $ROM_MD5;
            """;
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return games;
        }

        statement.bind_text (1, rom_md5);

        while (statement.step () == Sqlite.ROW) {
            var game = parse_game_row (statement);
            games.add (game);
        }
        statement.reset ();

        return games;
    }

    public Gee.List<Replay.Models.LibretroGameDetails> lookup_games_for_franchise (string franchise_name) {
        var games = new Gee.ArrayList<Replay.Models.LibretroGameDetails> ();

        var sql = """
            SELECT games.serial_id,
                games.release_year,
                games.release_month,
                games.display_name,
                games.description,
                developers.name as developer_name,
                franchises.name as franchise_name,
                regions.name as region_name,
                genres.name as genre_name,
                roms.name as rom_name,
                roms.md5 as rom_md5,
                platforms.name as platform_name,
                manufacturers.name as manufacturer_name
            FROM games
                LEFT JOIN developers ON games.developer_id = developers.id
                LEFT JOIN franchises ON games.franchise_id = franchises.id
                LEFT JOIN genres ON games.genre_id = genres.id
                LEFT JOIN platforms ON games.platform_id = platforms.id
                    LEFT JOIN manufacturers ON platforms.manufacturer_id = manufacturers.id
                LEFT JOIN regions ON games.region_id = regions.id
                INNER JOIN roms ON games.rom_id = roms.id
            WHERE franchises.name = $FRANCHISE_NAME;
            """;
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return games;
        }

        statement.bind_text (1, franchise_name);

        while (statement.step () == Sqlite.ROW) {
            var game = parse_game_row (statement);
            games.add (game);
        }
        statement.reset ();

        return games;
    }

    private Replay.Models.LibretroGameDetails parse_game_row (Sqlite.Statement statement) {
        var num_columns = statement.column_count ();
        var game = new Replay.Models.LibretroGameDetails ();
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "serial_id":
                    game.serial_id = statement.column_text (i);
                    break;
                case "release_year":
                    if (statement.column_text (i) == null) {
                        game.release_year = null;
                    } else {
                        game.release_year = statement.column_int (i);
                    }
                    break;
                case "release_month":
                    if (statement.column_text (i) == null) {
                        game.release_month = null;
                    } else {
                        game.release_month = statement.column_int (i);
                    }
                    break;
                case "display_name":
                    game.display_name = statement.column_text (i);
                    break;
                case "description":
                    game.description = statement.column_text (i);
                    break;
                case "developer_name":
                    game.developer_name = statement.column_text (i);
                    break;
                case "franchise_name":
                    game.franchise_name = statement.column_text (i);
                    break;
                case "region_name":
                    game.region_name = statement.column_text (i);
                    break;
                case "genre_name":
                    game.genre_name = statement.column_text (i);
                    break;
                case "rom_name":
                    game.rom_name = statement.column_text (i);
                    break;
                case "rom_md5":
                    game.rom_md5 = statement.column_text (i);
                    break;
                case "platform_name":
                    game.platform_name = statement.column_text (i);
                    break;
                case "manufacturer_name":
                    game.manufacturer_name = statement.column_text (i);
                    break;
                default:
                    break;
            }
        }
        return game;
    }

    private static void log_database_error (int errcode, string errmsg) {
        warning ("Database error: %d: %s", errcode, errmsg);
    }

}
