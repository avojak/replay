/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Replay.Layouts.LibraryLayout : Gtk.Grid {

    private static Gtk.CssProvider provider;

    private Replay.Widgets.LibrarySidePanel side_panel;
    private Gtk.Grid grid;
    private Replay.Widgets.GameGrid game_grid;
    private Granite.Widgets.AlertView alert_view;
    private Gtk.Stack stack;

    private Gee.Map<string, Replay.Models.LibraryItemFilterFunction> filter_mapping;

    public LibraryLayout () {
        Object (
            expand: true
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/AlertView.css");
    }

    construct {
        filter_mapping = new Gee.HashMap<string, Replay.Models.LibraryItemFilterFunction> ();

        var header_bar = new Replay.Widgets.MainHeaderBar ();
        side_panel = new Replay.Widgets.LibrarySidePanel ();
        side_panel.item_selected.connect (on_side_panel_item_selected);

        game_grid = new Replay.Widgets.GameGrid ();
        game_grid.item_selected.connect ((library_item) => {
            game_selected (library_item.game);
        });
        game_grid.item_added_to_favorites.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_favorite (library_item.game, true);
            game_grid.refilter ();
            update_side_panel_badges ();
        });
        game_grid.item_removed_from_favorites.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_favorite (library_item.game, false);
            game_grid.refilter ();
            update_side_panel_badges ();
        });
        game_grid.item_marked_played.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_played (library_item.game, true);
            game_grid.refilter ();
            update_side_panel_badges ();
        });
        game_grid.item_marked_unplayed.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_played (library_item.game, false);
            game_grid.refilter ();
            update_side_panel_badges ();
        });

        alert_view = new Granite.Widgets.AlertView ("", "", "");
        alert_view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        stack = new Gtk.Stack () {
            expand = true
        };
        stack.add_named (game_grid, "game-grid");
        stack.add_named (alert_view, "alert-view");

        grid = new Gtk.Grid () {
            expand = true
        };
        grid.attach (header_bar, 0, 0);
        grid.attach (stack, 0, 1);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 240
        };
        paned.pack1 (side_panel, false, false);
        paned.pack2 (grid, true, false);

        attach (paned, 0, 0);

        var header_group = new Hdy.HeaderGroup ();
        header_group.add_header_bar (side_panel.header_bar);
        header_group.add_header_bar (header_bar);

        show_all ();

        // TODO: Load from settings
        stack.set_visible_child_name ("game-grid");
    }

    public void add_collection (string display_name, string icon_name, string view_name, Replay.Models.LibraryItemFilterFunction filter_func) {
        // Add to the side panel
        side_panel.add_collection (display_name, icon_name, view_name);
        // Register the filter
        filter_mapping.set (view_name, filter_func);
        // Update badges
        update_side_panel_badges ();
    }

    public void add_game (Replay.Models.Game game) {
        game_grid.add_game (game);
        update_side_panel_badges ();
    }

    public void remove_game (Replay.Models.Game game) {
        game_grid.remove_game (game);
        update_side_panel_badges ();
    }

    public void select_view (string view_name) {
        side_panel.select_view (view_name);
    }

    private void on_side_panel_item_selected (Replay.Widgets.LibrarySidePanelItem item) {
        var filter_func = filter_mapping.get (item.view_name);
        Idle.add (() => {
            game_grid.set_filter_func (filter_func);
            // Need to switch back to the game grid so that get_visible_children() can
            // determine how many children are visible
            stack.set_visible_child_name ("game-grid");
            if (game_grid.get_visible_children () > 0) {
                stack.set_visible_child_name ("game-grid");
            } else {
                alert_view.title = filter_func.placeholder_title;
                alert_view.description = filter_func.placeholder_description;
                alert_view.icon_name = filter_func.placeholder_icon_name;
                stack.set_visible_child_name ("alert-view");
            }
            return false;
        });
    }

    private void update_side_panel_badges () {
        Idle.add (() => {
            foreach (var side_panel_item in side_panel.get_items ()) {
                var filter_func = filter_mapping.get (side_panel_item.view_name);
                int count = game_grid.count_visible_children (filter_func);
                side_panel_item.badge = count > 0 ? count.to_string () : "";
            }
            return false;
        });
    }

    public signal void game_selected (Replay.Models.Game game);

}
