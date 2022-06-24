/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.SQLClient : GLib.Object {

    private static GLib.Once<Replay.Services.SQLClient> instance;
    public static unowned Replay.Services.SQLClient get_default () {
        return instance.once (() => { return new Replay.Services.SQLClient (); });
    }

    private const string DATABASE_FILE = "replay.db";
    private const string SUPPORTED_EXTENSIONS_DELIM = ",";

    private Sqlite.Database database;

    private SQLClient () {
        info ("Database file: %s", DATABASE_FILE);
        initialize_database ();
    }

    private void initialize_database () {
        var config_dir_path = GLib.Environment.get_user_config_dir () + "/" + Constants.APP_ID;
        var config_dir_file = GLib.File.new_for_path (config_dir_path);
        try {
            if (!config_dir_file.query_exists ()) {
                debug ("Config directory does not exist - creating it now");
                config_dir_file.make_directory ();
            }
        } catch (GLib.Error e) {
            // TODO: Show an error message that we cannot proceed
            critical ("Error creating config directory: %s", e.message);
            return;
        }
        var db_file = config_dir_path + "/" + DATABASE_FILE;
        if (Sqlite.Database.open_v2 (db_file, out database) != Sqlite.OK) {
            // TODO: Show error message that we cannot proceed
            critical ("Can't open database: %d: %s", database.errcode (), database.errmsg ());
            return;
        }

        initialize_tables ();
    }

    private void initialize_tables () {
        string sql = """
            CREATE TABLE IF NOT EXISTS "cores" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "path" TEXT NOT NULL,
                "core_name" TEXT NOT NULL,
                "display_name" TEXT NOT NULL,
                "supported_extensions" TEXT NOT NULL,
                "manufacturer" TEXT NOT NULL,
                "system_id" TEXT NOT NULL,
                "system_name" TEXT NOT NULL,
                "license" TEXT NOT NULL,
                "display_version" TEXT,
                "description" TEXT
            );
            CREATE TABLE IF NOT EXISTS "games" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "rom_md5" TEXT NOT NULL,
                "is_favorite" BOOL NOT NULL,
                "is_played" BOOL NOT NULL,
                "last_played" INTEGER,
                "time_played" INTEGER NOT NULL
            );
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

    public void insert_core (Replay.Models.LibretroCore core) {
        var sql = """
            INSERT INTO cores (path, core_name, display_name, supported_extensions, manufacturer, system_id, system_name, license, display_version, description) 
            VALUES ($PATH, $CORE_NAME, $DISPLAY_NAME, SUPPORTED_EXTENSIONS, $MANUFACTURER, $SYSTEM_ID, $SYSTEM_NAME, $LICENSE, $DISPLAY_VERSION, $DESCRIPTION);
            """;

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }

        statement.bind_text (1, core.path);
        statement.bind_text (2, core.info.core_name);
        statement.bind_text (3, core.info.display_name);
        statement.bind_text (4, string.joinv (SUPPORTED_EXTENSIONS_DELIM, core.info.supported_extensions));
        statement.bind_text (5, core.info.manufacturer);
        statement.bind_text (6, core.info.system_id);
        statement.bind_text (7, core.info.system_name);
        statement.bind_text (8, core.info.license);
        statement.bind_text (9, core.info.display_version);
        statement.bind_text (10, core.info.description);

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    public Gee.List<Replay.Models.LibretroCore> get_cores () {
        var cores = new Gee.ArrayList<Replay.Models.LibretroCore> ();

        var sql = "SELECT * FROM cores;";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return cores;
        }

        while (statement.step () == Sqlite.ROW) {
            var server = parse_core_row (statement);
            cores.add (server);
        }
        statement.reset ();

        return cores;
    }

    private Replay.Models.LibretroCore parse_core_row (Sqlite.Statement statement) {
        var num_columns = statement.column_count ();
        var core = new Replay.Models.LibretroCore ();
        var core_info = new Replay.Models.LibretroCoreInfo ();
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "path":
                    core.path = statement.column_text (i);
                    break;
                case "core_name":
                    core_info.core_name = statement.column_text (i);
                    break;
                case "display_name":
                    core_info.display_name = statement.column_text (i);
                    break;
                case "supported_extensions":
                    core_info.supported_extensions = statement.column_text (i).split (SUPPORTED_EXTENSIONS_DELIM);
                    break;
                case "manufacturer":
                    core_info.manufacturer = statement.column_text (i);
                    break;
                case "system_id":
                    core_info.system_id = statement.column_text (i);
                    break;
                case "system_name":
                    core_info.system_name = statement.column_text (i);
                    break;
                case "license":
                    core_info.license = statement.column_text (i);
                    break;
                case "display_version":
                    core_info.display_version = statement.column_text (i);
                    break;
                case "description":
                    core_info.description = statement.column_text (i);
                    break;
                default:
                    break;
            }
        }
        core.info = core_info;
        return core;
    }

    public void insert_game (Replay.Models.Game game) {
        var sql = """
            INSERT INTO games (rom_md5, is_favorite, is_played, last_played, time_played) 
            VALUES ($ROM_MD5, $IS_FAVORITE, $IS_PLAYED, $LAST_PLAYED, $TIME_PLAYED);
            """;

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }

        statement.bind_text (1, game.rom_md5);
        statement.bind_int (2, bool_to_int (game.is_favorite));
        statement.bind_int (3, bool_to_int (game.is_played));
        if (game.last_played == null) {
            statement.bind_null (4);
        } else {
            statement.bind_int64 (4, game.last_played.to_unix ());
        }
        statement.bind_int (5, game.time_played);

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    public Replay.Models.Game.MetadataDAO? get_game (string rom_md5) {
        var sql = "SELECT * FROM games WHERE rom_md5 = $ROM_MD5;";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return null;
        }
        statement.bind_text (1, rom_md5);

        if (statement.step () != Sqlite.ROW) {
            return null;
        }
        var metadata = parse_game_row (statement);
        statement.reset ();
        return metadata;
    }

    public void update_game (Replay.Models.Game game) {
        var sql = """
            UPDATE games
            SET is_favorite = $IS_FAVORITE, is_played = $IS_PLAYED, last_played = $LAST_PLAYED, time_played = $TIME_PLAYED
            WHERE rom_md5 = $ROM_MD5;
            """;

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }
        statement.bind_int (1, bool_to_int (game.is_favorite));
        statement.bind_int (2, bool_to_int (game.is_played));
        if (game.last_played == null) {
            statement.bind_null (3);
        } else {
            statement.bind_int64 (3, game.last_played.to_unix ());
        }
        statement.bind_int (4, game.time_played);
        statement.bind_text (5, game.rom_md5);

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    public Replay.Models.Game.MetadataDAO parse_game_row (Sqlite.Statement statement) {
        var num_columns = statement.column_count ();
        var metadata = new Replay.Models.Game.MetadataDAO ();
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "rom_md5":
                    metadata.rom_md5 = statement.column_text (i);
                    break;
                case "is_favorite":
                    metadata.is_favorite = int_to_bool (statement.column_int (i));
                    break;
                case "is_played":
                    metadata.is_played = int_to_bool (statement.column_int (i));
                    break;
                case "last_played":
                    if (statement.column_type (i) == Sqlite.NULL) {
                        metadata.last_played = null;
                    } else {
                        metadata.last_played = statement.column_int64 (i);
                    }
                    break;
                case "time_played":
                    metadata.time_played = statement.column_int (i);
                    break;
                default:
                    break;
            }
        }
        return metadata;
    }

    private static int bool_to_int (bool val) {
        return val ? 1 : 0;
    }

    private static bool int_to_bool (int val) {
        return val == 1;
    }

    private static void log_database_error (int errcode, string errmsg) {
        warning ("Database error: %d: %s", errcode, errmsg);
    }

}
