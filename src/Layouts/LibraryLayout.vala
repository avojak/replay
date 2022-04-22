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

    private Replay.Widgets.MainHeaderBar header_bar;
    private Replay.Widgets.LibrarySidePanel side_panel;
    private Gtk.Grid grid;
    private Replay.Widgets.GameGrid game_grid;
    //  private Granite.Widgets.AlertView alert_view;
    private Replay.Views.GameDetailView detail_view;
    //  private Gtk.Revealer searchbar_revealer;
    //  private Gtk.SearchEntry search_entry;
    private Gtk.Stack stack;

    private Gee.Map<string, Replay.Models.LibraryItemFilterFunction> filter_mapping;
    private Gee.Map<string, Replay.Models.LibraryItemSortFunction> sort_mapping;

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
        sort_mapping = new Gee.HashMap<string, Replay.Models.LibraryItemSortFunction> ();

        header_bar = new Replay.Widgets.MainHeaderBar ();
        header_bar.view_return.connect (on_return_button_clicked);
        header_bar.search_changed.connect (on_search_changed);

        side_panel = new Replay.Widgets.LibrarySidePanel ();
        side_panel.item_selected.connect (on_side_panel_item_selected);

        game_grid = new Replay.Widgets.GameGrid ();
        game_grid.item_selected.connect ((library_item) => {
            Idle.add (() => {
                //  set_searchbar_visible (false);
                detail_view.set_library_item (library_item);
                stack.set_visible_child_full ("detail-view", Gtk.StackTransitionType.SLIDE_LEFT);
                header_bar.set_return_button_visible (true);
                return false;
            });
        });
        game_grid.item_run.connect ((library_item) => {
            game_selected (library_item.game);
            Idle.add (() => {
                library_item.set_played (true);
                invalidate_sort ();
                invalidate_filter ();
                return false;
            });
        });
        game_grid.item_added_to_favorites.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_favorite (library_item.game, true); // TODO: Do this a level up?
            Idle.add (() => {
                invalidate_filter ();
                update_side_panel_badges ();
                return false;
            });
        });
        game_grid.item_removed_from_favorites.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_favorite (library_item.game, false);
            Idle.add (() => {
                invalidate_filter ();
                update_side_panel_badges ();
                return false;
            });
        });
        game_grid.item_marked_played.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_played (library_item.game, true);
            Idle.add (() => {
                library_item.set_played (true);
                invalidate_filter ();
                update_side_panel_badges ();
                return false;
            });
        });
        game_grid.item_marked_unplayed.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_played (library_item.game, false);
            Idle.add (() => {
                library_item.set_played (false);
                invalidate_filter ();
                update_side_panel_badges ();
                return false;
            });
        });

        //  alert_view = new Granite.Widgets.AlertView ("", "", "");
        //  alert_view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        detail_view = new Replay.Views.GameDetailView ();
        detail_view.play_button_clicked.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_played (library_item.game, true);
            Idle.add (() => {
                //  invalidate_filter ();
                library_item.set_played (true);
                update_side_panel_badges ();
                return false;
            });
            game_selected (library_item.game);
        });
        detail_view.item_added_to_favorites.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_favorite (library_item.game, true);
            Idle.add (() => {
                update_side_panel_badges ();
                return false;
            });
        });
        detail_view.item_removed_from_favorites.connect ((library_item) => {
            Replay.Core.Client.get_default ().game_library.set_game_favorite (library_item.game, false);
            Idle.add (() => {
                update_side_panel_badges ();
                return false;
            });
        });

        stack = new Gtk.Stack () {
            expand = true
        };
        stack.add_named (game_grid, "game-grid");
        //  stack.add_named (alert_view, "alert-view");
        stack.add_named (detail_view, "detail-view");

        //  searchbar_revealer = new Gtk.Revealer () {
        //      hexpand = true,
        //      transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        //  };
        //  search_entry = new Gtk.SearchEntry () {
        //      margin = 8
        //  };
        //  search_entry.search_changed.connect (() => {
        //      Idle.add (() => {
        //          if (stack.get_visible_child_name () == "detail-view") {
        //              header_bar.set_return_button_visible (false);
        //              stack.set_visible_child_full ("game-grid", Gtk.StackTransitionType.SLIDE_RIGHT);
        //          }
        //          game_grid.invalidate_filter ();
        //          update_visible_stack_child ();
        //          return false;
        //      });
        //  });
        //  searchbar_revealer.add (search_entry);

        var stack_grid = new Gtk.Grid () {
            expand = true
        };
        //  stack_grid.attach (searchbar_revealer, 0, 0);
        stack_grid.attach (stack, 0, 0);

        grid = new Gtk.Grid () {
            expand = true
        };
        grid.attach (header_bar, 0, 0);
        grid.attach (stack_grid, 0, 1);

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
    }

    private void on_return_button_clicked () {
        Idle.add (() => {
            header_bar.set_return_button_visible (false);
            stack.set_visible_child_full ("game-grid", Gtk.StackTransitionType.SLIDE_RIGHT);
            //  invalidate_filter ();
            //  update_visible_stack_child (); // Already handled in invalidate_filter()
            return false;
        });
    }

    private void on_search_changed (string search_text) {
        if (stack.get_visible_child_name () == "detail-view") {
            on_return_button_clicked ();
        }
        if (search_text.length == 0) {
            game_grid.set_filter_func (new Models.LibraryItemFilterFunction (_("No Games Found"), _("Try changing search terms."), "system-search", (library_item) => {
                return true;
            }));
            side_panel.set_enabled (true);
            //  update_visible_stack_child ();
        } else {
            var filter_func = new Models.LibraryItemFilterFunction (_("No Games Found"), _("Try changing search terms."), "system-search", (library_item) => {
                return library_item.game.display_name.down ().contains (search_text.down ());
            });
            //  alert_view.title = filter_func.placeholder_title;
            //  alert_view.description = filter_func.placeholder_description;
            //  alert_view.icon_name = filter_func.placeholder_icon_name;
            game_grid.set_filter_func (filter_func);
            game_grid.set_sort_func (new Models.LibraryItemSortFunction ((item_a, item_b) => {
                return item_a.game.display_name.ascii_casecmp (item_b.game.display_name);
            }));
            side_panel.select_none ();
            side_panel.set_enabled (false);
            //  update_visible_stack_child ();
        }
    }

    public void add_collection (string display_name, string icon_name, string view_name, Replay.Models.LibraryItemFilterFunction filter_func, Replay.Models.LibraryItemSortFunction sort_func) {
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

    public void add_game (Replay.Models.Game game) {
        game_grid.add_game (game);
        Idle.add (() => {
            update_side_panel_badges ();
            return false;
        });
    }

    public void remove_game (Replay.Models.Game game) {
        game_grid.remove_game (game);
        Idle.add (() => {
            update_side_panel_badges ();
            return false;
        });
    }

    public void select_view (string view_name) {
        side_panel.select_view (view_name);
    }

    public void set_searchbar_visible (bool visible) {
        //  if (visible) {
        //      if (stack.get_visible_child_name () == "detail-view") {
        //          on_return_button_clicked ();
        //      }
        //      side_panel.select_none ();
        //      side_panel.set_enabled (false);
        //      header_bar.update_find_button_state (true);
        //      searchbar_revealer.set_reveal_child (true);
        //      search_entry.grab_focus ();
        //      var filter_func = new Models.LibraryItemFilterFunction (_("No Games Found"), _("Try changing search terms."), "system-search", (library_item) => {
        //          if (search_entry.get_text ().strip ().length == 0) {
        //              return true;
        //          }
        //          return library_item.game.display_name.down ().contains (search_entry.get_text ().strip ().down ());
        //      });
        //      game_grid.set_filter_func (filter_func);
        //      alert_view.title = filter_func.placeholder_title;
        //      alert_view.description = filter_func.placeholder_description;
        //      alert_view.icon_name = filter_func.placeholder_icon_name;
        //      game_grid.set_sort_func (new Models.LibraryItemSortFunction ((item_a, item_b) => {
        //          return item_a.game.display_name.ascii_casecmp (item_b.game.display_name);
        //      }));
        //      Idle.add (() => {
        //          update_visible_stack_child ();
        //          return false;
        //      });
        //  } else {
        //      search_entry.set_text ("");
        //      side_panel.set_enabled (true);
        //      header_bar.update_find_button_state (false);
        //      searchbar_revealer.set_reveal_child (false);
        //  }
    }

    /*
     * Force the game grid to be resorted. For example, in the case where the display name of a game has
     * changed and we need to ensure proper sorting.
     */
    private void invalidate_sort () {
        //  Idle.add (() => {
            game_grid.invalidate_sort ();
            //  return false;
        //  });
    }

    /*
     * Force the game grid to be refiltered. For example, in the case where the state of an item has changed
     * and we need to ensure the change in visibility.
     */
     private void invalidate_filter () {
        //  Idle.add (() => {
        game_grid.invalidate_filter ();
        update_visible_stack_child ();
            //  return false;
        //  });
    }

    private void on_side_panel_item_selected (Replay.Widgets.LibrarySidePanelItem item) {
        var filter_func = filter_mapping.get (item.view_name);
        var sort_func = sort_mapping.get (item.view_name);
        Idle.add (() => {
            set_searchbar_visible (false);
            header_bar.set_return_button_visible (false);
            if (stack.get_visible_child_name () == "detail-view") {
                stack.set_visible_child_full ("game-grid", Gtk.StackTransitionType.SLIDE_RIGHT);
            }
            game_grid.set_sort_func (sort_func);
            game_grid.set_filter_func (filter_func);
            // Always update the alert view text in case a refilter occurs later without selecting a new side panel item
            //  alert_view.title = filter_func.placeholder_title;
            //  alert_view.description = filter_func.placeholder_description;
            //  alert_view.icon_name = filter_func.placeholder_icon_name;
            update_visible_stack_child ();
            return false;
        });
    }

    /*
     * Check the number of visible items in the game grid and determine whether the game grid should be shown,
     * or the alert view in the event of no visibile items.
     */
    private void update_visible_stack_child () {
        // TODO: Would it be better to check the side panel badge than trying to evaluate the number of visible children?

        // Need to switch back to the game grid so that get_visible_children() can
        // determine how many children are visible
        //  stack.set_visible_child_name ("game-grid");
        //  if (game_grid.get_visible_children () > 0) {
        //      stack.set_visible_child_name ("game-grid");
        //  } else {
        //      stack.set_visible_child_name ("alert-view");
        //  }
    }

    /*
     * Update the badges for side panel items. For example, in the case a new game being added to the game grid.
     */
    private void update_side_panel_badges () {
        //  Idle.add (() => {
            foreach (var side_panel_item in side_panel.get_items ()) {
                var filter_func = filter_mapping.get (side_panel_item.view_name);
                int count = game_grid.count_visible_children (filter_func);
                side_panel_item.badge = count > 0 ? count.to_string () : "";
            }
        //      return false;
        //  });
    }

    public void toggle_sidebar () {
        side_panel.visible = !side_panel.visible;
    }

    public signal void game_selected (Replay.Models.Game game);

}
