/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Layouts.LibraryLayout : Gtk.Grid {

    private static Gtk.CssProvider provider;

    private Replay.Widgets.MainHeaderBar header_bar;
    private Replay.Widgets.LibrarySidePanel side_panel;
    private Gtk.Grid grid;
    private Replay.Widgets.GameGrid game_grid;
    private Gtk.Stack stack;

    private Gee.Map<string, Replay.Models.Functions.LibraryItemFilterFunction> filter_mapping;
    private Gee.Map<string, Replay.Models.Functions.LibraryItemSortFunction> sort_mapping;

    private GLib.Queue<string> detail_view_names;

    private string? current_search_text;

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
        filter_mapping = new Gee.HashMap<string, Replay.Models.Functions.LibraryItemFilterFunction> ();
        sort_mapping = new Gee.HashMap<string, Replay.Models.Functions.LibraryItemSortFunction> ();

        detail_view_names = new GLib.Queue<string> ();

        header_bar = new Replay.Widgets.MainHeaderBar ();
        header_bar.view_return.connect (on_return_button_clicked);
        header_bar.search_changed.connect (on_search_changed);

        side_panel = new Replay.Widgets.LibrarySidePanel ();
        side_panel.item_selected.connect (on_side_panel_item_selected);

        game_grid = new Replay.Widgets.GameGrid ();
        game_grid.item_selected.connect ((library_item) => {
            on_library_item_selected (library_item);
        });
        game_grid.item_run.connect ((library_item, core_name) => {
            game_selected (library_item.game, core_name);
        });

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            expand = true
        };
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (game_grid);

        stack = new Gtk.Stack () {
            expand = true
        };
        stack.add_named (scrolled_window, "game-grid");
        stack.add_named (new Replay.Views.LibraryLoadingView (), Replay.Views.LibraryLoadingView.NAME);

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
        //  stack.set_visible_child_name ("game-grid");
        stack.set_visible_child_name (Replay.Views.LibraryLoadingView.NAME);
    }

    private Replay.Views.GameDetailView create_detail_view (Replay.Widgets.LibraryItem library_item) {
        var detail_view = new Replay.Views.GameDetailView.for_library_item (library_item);
        detail_view.item_selected.connect (on_library_item_selected);
        detail_view.play_button_clicked.connect ((library_item, core_name) => {
            game_selected (library_item.game, core_name);
        });
        return detail_view;
    }

    private void on_library_item_selected (Replay.Widgets.LibraryItem library_item) {
        if (detail_view_names.is_empty ()) {
            header_bar.set_return_button_game (null);
        } else {
            header_bar.set_return_button_game (detail_view_names.peek_tail ());
        }
        header_bar.set_return_button_visible (true);

        // Don't create a view if it already exists
        var view_name = library_item.game.display_name;
        if (stack.get_child_by_name (view_name) == null) {
            var detail_view = create_detail_view (library_item);
            stack.add_named (detail_view, view_name);
        }
        detail_view_names.push_tail (view_name);
        Idle.add (() => {
            ((Replay.Views.GameDetailView) stack.get_child_by_name (view_name)).reset_scroll ();
            stack.set_visible_child_full (view_name, Gtk.StackTransitionType.SLIDE_LEFT);
            return false;
        });
    }

    private void on_return_button_clicked () {
        Idle.add (() => {
            //  header_bar.set_return_button_visible (false);
            detail_view_names.pop_tail ();
            if (detail_view_names.is_empty ()) {
                header_bar.set_return_button_visible (false);
                stack.set_visible_child_full ("game-grid", Gtk.StackTransitionType.SLIDE_RIGHT);
            } else {
                if (detail_view_names.length == 1) {
                    header_bar.set_return_button_game (null);
                } else {
                    header_bar.set_return_button_game (detail_view_names.peek_nth (detail_view_names.length - 2));
                }
                stack.set_visible_child_full (detail_view_names.peek_tail (), Gtk.StackTransitionType.SLIDE_RIGHT);
            }
            invalidate_filter (); // This is necessary for some reason…
            //  update_visible_stack_child (); // Already handled in invalidate_filter()
            return false;
        });
    }

    private void on_search_changed (string search_text) {
        // Need to hold an instance of this string for the filter function
        // TODO: May not be needed anymore with new function object
        current_search_text = search_text;

        if (!detail_view_names.is_empty ()) {
            stack.set_visible_child_full ("game-grid", Gtk.StackTransitionType.SLIDE_RIGHT);
            detail_view_names.clear ();
        }
        if (search_text.length == 0) {
            game_grid.set_filter_func (new Replay.Models.Functions.SearchResultsFilterFunction (search_text));
            side_panel.set_enabled (true);
        } else {
            var filter_func = new Replay.Models.Functions.SearchResultsFilterFunction (search_text);
            game_grid.set_filter_func (filter_func);
            game_grid.set_sort_func (new Replay.Models.Functions.AlphabeticalSortFunction ());
            side_panel.select_none ();
            side_panel.set_enabled (false);
        }
    }

    public void add_collection (string display_name, string icon_name, string view_name, Replay.Models.Functions.LibraryItemFilterFunction filter_func, Replay.Models.Functions.LibraryItemSortFunction sort_func) {
        // Add to the side panel
        side_panel.add_collection (display_name, icon_name, view_name);
        // Register the filter
        filter_mapping.set (view_name, filter_func);
        sort_mapping.set (view_name, sort_func);
        // Update badges
        Idle.add (() => {
            update_side_panel_badges ();
            return false;
        });
    }

    public void add_system (string display_name, string icon_name, string view_name, Replay.Models.Functions.LibraryItemFilterFunction filter_func, Replay.Models.Functions.LibraryItemSortFunction sort_func) {
        // Add to the side panel
        side_panel.add_system (display_name, icon_name, view_name);
        // Register the filter
        filter_mapping.set (view_name, filter_func);
        sort_mapping.set (view_name, sort_func);
        // Update badges
        Idle.add (() => {
            update_side_panel_badges ();
            return false;
        });
    }

    public void add_game (Replay.Models.Game game) {
        game_grid.add_game (game);
        game.notify["is-favorite"].connect (on_game_property_changed);
        game.notify["is-played"].connect (on_game_property_changed);
        game.notify["last-played"].connect (on_game_property_changed);
        Idle.add (() => {
            update_side_panel_badges ();
            invalidate_filter ();
            return false;
        });
    }

    private void on_game_property_changed (GLib.Object source, GLib.ParamSpec property) {
        Idle.add (() => {
            invalidate_filter ();
            update_side_panel_badges ();
            return false;
        });
    }

    public void remove_game (Replay.Models.Game game) {
        game_grid.remove_game (game);
        Idle.add (() => {
            update_side_panel_badges ();
            invalidate_filter ();
            return false;
        });
    }

    public void select_view (string view_name) {
        side_panel.select_view (view_name);
    }

    public void expand_systems_category () {
        Idle.add (() => {
            side_panel.expand_systems_category ();
            return false;
        });
    }

    /*
     * Force the game grid to be refiltered. For example, in the case where the state of an item has changed
     * and we need to ensure the change in visibility.
     */
    private void invalidate_filter () {
        game_grid.invalidate_filter ();
    }

    private void on_side_panel_item_selected (Replay.Widgets.LibrarySidePanelItem item) {
        var filter_func = filter_mapping.get (item.view_name);
        var sort_func = sort_mapping.get (item.view_name);
        Idle.add (() => {
            header_bar.set_return_button_visible (false);
            if (!detail_view_names.is_empty ()) {
                stack.set_visible_child_full ("game-grid", Gtk.StackTransitionType.SLIDE_RIGHT);
                detail_view_names.clear ();
            }
            game_grid.set_sort_func (sort_func);
            game_grid.set_filter_func (filter_func);
            return false;
        });
    }

    /*
     * Update the badges for side panel items. For example, in the case a new game being added to the game grid.
     */
    private void update_side_panel_badges () {
        foreach (var side_panel_item in side_panel.get_items ()) {
            var filter_func = filter_mapping.get (side_panel_item.view_name);
            int count = game_grid.count_visible_children (filter_func);
            side_panel_item.badge = count > 0 ? count.to_string () : "";
        }
    }

    public void toggle_sidebar () {
        side_panel.visible = !side_panel.visible;
    }

    public void show_loading_view () {
        stack.set_visible_child_name (Replay.Views.LibraryLoadingView.NAME);
    }

    public void hide_loading_view () {
        Idle.add (() => {
            stack.set_visible_child_name ("game-grid");
            return false;
        });
    }

    public void show_processing (bool processing) {
        header_bar.set_spinner_visible (processing);
    }

    public signal void game_selected (Replay.Models.Game game, string? core_name);

}
