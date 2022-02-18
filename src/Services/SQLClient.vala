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

public class Replay.Services.SQLClient : GLib.Object {

    private const string DATABASE_FILE = "replay.db";

    private Sqlite.Database database;

    private static Replay.Services.SQLClient _instance = null;
    public static Replay.Services.SQLClient instance {
        get {
            if (_instance == null) {
                _instance = new Replay.Services.SQLClient ();
            }
            return _instance;
        }
    }

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
            CREATE TABLE IF NOT EXISTS "servers" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "hostname" TEXT NOT NULL,
                "port" INTEGER NOT NULL,
                "nickname" TEXT NOT NULL,
                "username" TEXT NOT NULL,
                "realname" TEXT NOT NULL,
                "auth_method" TEXT NOT NULL,
                "tls" BOOL NOT NULL,
                "enabled" BOOL NOT NULL,
                "network_name" TEXT
            );
            CREATE TABLE IF NOT EXISTS "channels" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "server_id" INTEGER,
                "channel" TEXT,
                "enabled" BOOL,
                "favorite" BOOL
            );
            CREATE TABLE IF NOT EXISTS "server_identities" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "host" TEXT,
                "certificate_pem" TEXT,
                "is_accepted" BOOL
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

    public Gee.List<Replay.Models.LibretroCore> get_cores () {
        // TODO: Implement
        return new Gee.ArrayList<Replay.Models.LibretroCore> ();
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