/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.TheGamesDBClient : GLib.Object {

    private const string BASE_URL = "https://api.thegamesdb.net";

    public TheGamesDBClient () {

    }

    public void search_games (string name) {
        string api_key = Constants.THE_GAMES_DB_API_PUBLIC_KEY;
        string search_string = Soup.URI.encode (name, null);
        string fields = Soup.URI.encode (string.join (",", "overview", "rating"), null);
        string url = @"$BASE_URL/v1.1/Games/ByGameName?apikey=$api_key&name=$search_string&fields=$fields";

        var message = new Soup.Message ("GET", url);
        message.request_headers.append ("accept", "application/json");

        Soup.Session session = new Soup.Session ();
        session.send_message (message);

        switch (message.status_code) {
            case 200:
                var parser = new Json.Parser ();
                try {
                    parser.load_from_data ((string) message.response_body.data);
                    var data_object = parser.get_root ().get_object ().get_object_member ("data");
                    var count = data_object.get_int_member ("count");
                    if (count == 0) {
                        warning ("No search results for \"%s\"", name);
                        return;
                    }
                    if (count > 1) {
                        warning ("Multiple search results for \"%s\", using first", name);
                    }
                    var game_object = data_object.get_array_member ("games").get_element (0).get_object ();
                    var id = game_object.get_int_member ("id");
                    var game_title = game_object.get_string_member ("game_title");
                    string? overview = game_object.has_member ("overview") ? game_object.get_string_member ("overview") : null;
                    string? rating = game_object.has_member ("rating") ? game_object.get_string_member ("rating") : null;
                } catch (GLib.Error e) {
                    warning ("Error parsing JSON response: %s", e.message);
                }
                break;
            case 400:
                warning ("Bad request");
                break;
            case 403:
                break;
            default:
                warning ("Unexpected status code");
                break;
        }
    }

}
