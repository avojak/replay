/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.LibraryView : Gtk.Grid {

    private const int RECENTLY_PLAYED_THRESHOLD_DAYS = 30;

    private const string ALL_VIEW_NAME = "collection:all";
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
        library_layout.add_collection (_("All Games"), "folder-saved-search", ALL_VIEW_NAME, new Replay.Models.LibraryItemFilterFunction (
            _("No Games"),
            _("Games which have been added to your library will appear here"),
            "folder-saved-search",
            (library_item) => {
                return true;
            }),
            new Replay.Models.LibraryItemSortFunction ((library_item_1, library_item_2) => {
                return library_item_1.game.display_name.ascii_casecmp (library_item_2.game.display_name);
            })
        );
        library_layout.add_collection (_("Favorites"), "starred", FAVORITES_VIEW_NAME, new Replay.Models.LibraryItemFilterFunction (
            _("No Favorite Games"),
            _("Games which have been starred will appear here"),
            "user-bookmarks",
            (library_item) => {
                return library_item.game.is_favorite;
            }),
            new Replay.Models.LibraryItemSortFunction ((library_item_1, library_item_2) => {
                return library_item_1.game.display_name.ascii_casecmp (library_item_2.game.display_name);
            })
        );
        library_layout.add_collection (_("Recently Played"), "document-open-recent", RECENT_VIEW_NAME, new Replay.Models.LibraryItemFilterFunction (
            _("No Recent Games"),
            _("Games which have been recently played will appear here"),
            "document-open-recent",
            (library_item) => {
                return (library_item.game.last_played != null) && (library_item.game.last_played.difference (new GLib.DateTime.now_utc ()) <= (RECENTLY_PLAYED_THRESHOLD_DAYS * GLib.TimeSpan.DAY));
            }),
            new Replay.Models.LibraryItemSortFunction ((library_item_1, library_item_2) => {
                if (library_item_1.game.last_played == null || library_item_2.game.last_played == null) {
                    // Don't need to get fancy here - if one or both are null, the visual filter will take care of it anyway
                    return 0;
                }
                return -1 * library_item_1.game.last_played.compare (library_item_2.game.last_played);
            })
        );
        library_layout.add_collection (_("Unplayed"), "mail-unread", UNPLAYED_VIEW_NAME, new Replay.Models.LibraryItemFilterFunction (
            _("No Unplayed Games"),
            _("Games which have not yet been played will appear here"),
            "unplayed-game", // TODO: Find a suitable icon of the right size
            (library_item) => {
                return !library_item.game.is_played;
            }),
            new Replay.Models.LibraryItemSortFunction ((library_item_1, library_item_2) => {
                return library_item_1.game.display_name.ascii_casecmp (library_item_2.game.display_name);
            })
        );

        library_layout.game_selected.connect ((game) => {
            game_selected (game);
        });

        attach (library_layout, 0, 0);

        show_all ();

        // TODO: Load last-shown view, or show welcome view
        library_layout.select_view (ALL_VIEW_NAME);
    }

    public void add_game (Replay.Models.Game game) {
        library_layout.add_game (game);
    }

    public void toggle_sidebar () {
        library_layout.toggle_sidebar ();
    }

    public void set_searchbar_visible (bool visible) {
        library_layout.set_searchbar_visible (visible);
    }

    public signal void game_selected (Replay.Models.Game game);

}
