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

public class Replay.Views.LibraryView : Gtk.Grid {

    private const string FAVORITES_VIEW_NAME = "collection:favorites";
    private const string RECENT_VIEW_NAME = "collection:recent";
    private const string UNPLAYED_VIEW_NAME = "collection:unplayed";

    private Replay.Layouts.LibraryLayout library_layout;

    public LibraryView () {
        Object (
            expand: true
        );
    }

    construct {
        library_layout = new Replay.Layouts.LibraryLayout ();
        library_layout.add_collection (_("Favorites"), "starred", FAVORITES_VIEW_NAME, new Replay.Models.LibraryItemFilterFunction (
            _("No Favorite Games"),
            _("Games which have been starred will appear here"),
            "user-bookmarks",
            (library_item) => {
                //  debug ("%s is favorite: %s", library_item.game.display_name, library_item.game.is_favorite.to_string ());
                return library_item.game.is_favorite;
            }));
        library_layout.add_collection (_("Recently Played"), "document-open-recent", RECENT_VIEW_NAME, new Replay.Models.LibraryItemFilterFunction (
            _("No Recent Games"),
            _("Games which have been recently played will appear here"),
            "document-open-recent",
            (library_item) => {
                //  debug ("%s is recently played: %s", library_item.game.display_name, library_item.game.is_recently_played.to_string ());
                return library_item.game.is_recently_played;
            }
        ));
        library_layout.add_collection (_("Unplayed"), "mail-unread", UNPLAYED_VIEW_NAME, new Replay.Models.LibraryItemFilterFunction (
            _("No Unplayed Games"),
            _("Games which have not yet been played will appear here"),
            "mail-unread", // TODO: Find a suitable icon of the right size
            (library_item) => {
                //  debug ("%s is played: %s", library_item.game.display_name, library_item.game.is_played.to_string ());
                return !library_item.game.is_played;
            }
        ));

        library_layout.game_selected.connect ((game) => {
            game_selected (game);
        });

        attach (library_layout, 0, 0);

        show_all ();

        // TODO: Load last-shown view, or show welcome view
        library_layout.select_view (FAVORITES_VIEW_NAME);
    }

    public void add_game (Replay.Models.Game game) {
        library_layout.add_game (game);
    }

    public signal void game_selected (Replay.Models.Game game);

}
