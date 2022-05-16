/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

/**
 * Base filter function for filtering which items in the library view are visible.
 */
public abstract class Replay.Models.Functions.LibraryItemFilterFunction : GLib.Object {

    public string placeholder_title { get; set; }
    public string placeholder_description { get; set; }
    public string placeholder_icon_name { get; set; }

    public abstract bool filter (Replay.Widgets.LibraryItem library_item);

}

/**
 * Filter function for showing all games.
 */
public class Replay.Models.Functions.AllGamesFilterFunction : Replay.Models.Functions.LibraryItemFilterFunction {

    public AllGamesFilterFunction () {
        Object (
            placeholder_title: _("No Games"),
            placeholder_description: _("Games which have been added to your library will appear here"),
            placeholder_icon_name: "folder-saved-search"
        );
    }

    public override bool filter (Replay.Widgets.LibraryItem library_item) {
        return true;
    }

}

/**
 * Filter function for showing favorited games.
 */
public class Replay.Models.Functions.FavoritesFilterFunction : Replay.Models.Functions.LibraryItemFilterFunction {

    public FavoritesFilterFunction () {
        Object (
            placeholder_title: _("No Favorite Games"),
            placeholder_description: _("Games which have been starred will appear here"),
            placeholder_icon_name: "user-bookmarks"
        );
    }

    public override bool filter (Replay.Widgets.LibraryItem library_item) {
        return library_item.game.is_favorite;
    }

}

/**
 * Filter function for showing recently-played games.
 */
public class Replay.Models.Functions.RecentsFilterFunction : Replay.Models.Functions.LibraryItemFilterFunction {

    private const int RECENTLY_PLAYED_THRESHOLD_DAYS = 30;

    public RecentsFilterFunction () {
        Object (
            placeholder_title: _("No Recent Games"),
            placeholder_description: _("Games which have been recently played will appear here"),
            placeholder_icon_name: "document-open-recent"
        );
    }

    public override bool filter (Replay.Widgets.LibraryItem library_item) {
        return (library_item.game.last_played != null) && (library_item.game.last_played.difference (new GLib.DateTime.now_utc ()) <= (RECENTLY_PLAYED_THRESHOLD_DAYS * GLib.TimeSpan.DAY));
    }

}

/**
 * Filter function for showing unplayed games.
 */
public class Replay.Models.Functions.UnplayedFilterFunction : Replay.Models.Functions.LibraryItemFilterFunction {

    public UnplayedFilterFunction () {
        Object (
            placeholder_title: _("No Unplayed Games"),
            placeholder_description: _("Games which have not yet been played will appear here"),
            placeholder_icon_name: "unplayed-game"
        );
    }

    public override bool filter (Replay.Widgets.LibraryItem library_item) {
        return !library_item.game.is_played;
    }

}

/**
 * Filter function for showing search results.
 */
public class Replay.Models.Functions.SearchResultsFilterFunction : Replay.Models.Functions.LibraryItemFilterFunction {

    public string search_text { get; construct; }

    public SearchResultsFilterFunction (string search_text) {
        Object (
            search_text: search_text,
            placeholder_title: _("No Games Found"),
            placeholder_description: _("Try changing search terms"),
            placeholder_icon_name: "system-search"
        );
    }

    public override bool filter (Replay.Widgets.LibraryItem library_item) {
        return library_item.game.display_name.down ().contains (search_text.down ());
    }

}

/**
 * Filter function for showing games for a specific platform.
 */
public class Replay.Models.Functions.PlatformFilterFunction : Replay.Models.Functions.LibraryItemFilterFunction {

    public string platform_name { get; construct; }

    public PlatformFilterFunction (string platform_name) {
        Object (
            platform_name: platform_name,
            placeholder_title: _("No %s Games").printf (platform_name),
            placeholder_description: _("%s games in the library will appear here").printf (platform_name),
            placeholder_icon_name: "input-gaming"
        );
    }

    public override bool filter (Replay.Widgets.LibraryItem library_item) {
        return (library_item.game.libretro_details) != null && (library_item.game.libretro_details.platform_name == platform_name);
    }

}
