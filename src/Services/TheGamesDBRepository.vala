/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.TheGamesDBRepository : GLib.Object {

    private static GLib.Once<Replay.Services.TheGamesDBRepository> instance;
    public static unowned Replay.Services.TheGamesDBRepository get_default () {
        return instance.once (() => { return new Replay.Services.TheGamesDBRepository (); });
    }

    private const string DATABASE_FILE = "thegamesdb.sqlite";

    private Sqlite.Database database;

    private TheGamesDBRepository () {
        info ("Database file: %s", Constants.THE_GAMES_DB_DIR + "/" + DATABASE_FILE);
        initialize_database ();
    }

    private void initialize_database () {
        var db_file = Constants.THE_GAMES_DB_DIR + "/" + DATABASE_FILE;
        if (Sqlite.Database.open_v2 (db_file, out database) != Sqlite.OK) {
            // TODO: Show error message?
            critical ("Can't open database: %d: %s", database.errcode (), database.errmsg ());
            return;
        }

        initialize_tables ();
    }

    private void initialize_tables () {
        string sql = """
            
            """;
        database.exec (sql);

        do_upgrades ();
    }

    private void do_upgrades () {
        int? user_version = get_user_version ();
        if (user_version == null) {
            warning ("Null user_version, skipping upgrades");
            return;
        }
        if (user_version == 0) {
            debug ("SQLite user_version: %d, no upgrades to perform", user_version);
        }
    }

    private int? get_user_version () {
        var sql = "PRAGMA user_version";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return null;
        }

        if (statement.step () != Sqlite.ROW) {
            return null;
        }
        var num_columns = statement.column_count ();
        int? user_version = null;
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "user_version":
                    user_version = statement.column_int (i);
                    break;
                default:
                    break;
            }
        }
        statement.reset ();
        return user_version;
    }

    //  private void set_user_version (int user_version) {
    //      var sql = @"PRAGMA user_version = $user_version";
    //      Sqlite.Statement statement;
    //      if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
    //          log_database_error (database.errcode (), database.errmsg ());
    //          return;
    //      }
    //      string err_msg;
    //      int ec = database.exec (statement.expanded_sql (), null, out err_msg);
    //      if (ec != Sqlite.OK) {
    //          log_database_error (ec, err_msg);
    //          debug ("SQL statement: %s", statement.expanded_sql ());
    //      }
    //      statement.reset ();
    //  }

    // TODO: This should probably lookup all the games we want at once, rather than making multiple DB calls
    public Gee.List<Replay.Models.LibretroGameDetails> lookup_for_md5 (string rom_md5) {
        var games = new Gee.ArrayList<Replay.Models.LibretroGameDetails> ();

        var sql = """
            
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
                case "full_name":
                    game.full_name = statement.column_text (i);
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
