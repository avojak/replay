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

    private const string FAVORITES_VIEW_NAME = "favorites";
    private const string RECENT_VIEW_NAME = "recent";
    private const string UNPLAYED_VIEW_NAME = "unplayed";

    public unowned Replay.Windows.LibraryWindow window { get; construct; }

    private Gtk.Stack library_stack;
    //  private Gee.Map<string, Gtk.Widget> stack_views;
    private Replay.Widgets.LibrarySidePanel library_side_panel;

    public LibraryLayout (Replay.Windows.LibraryWindow window) {
        Object (
            window: window
        );
    }

    construct {
        var library_grid = new Gtk.Grid () {
            expand = true
        };
        var header_bar = new Replay.Widgets.MainHeaderBar ();

        library_stack = new Gtk.Stack ();
        library_stack.add_named (new Replay.Views.WelcomeView (), Replay.Views.WelcomeView.NAME);

        library_grid.attach (header_bar, 0, 0);
        library_grid.attach (library_stack, 0, 1);

        library_side_panel = new Replay.Widgets.LibrarySidePanel ();
        library_side_panel.item_selected.connect (on_side_panel_item_selected);

        add_collection_view (
            _("Favorites"),
            FAVORITES_VIEW_NAME,
            "starred",
            _("No Favorite Games"),
            _("Games which have been starred will appear here"),
            "user-bookmarks" // TODO: Find a suitable icon of the right size
        );
        add_collection_view (
            _("Recently Played"),
            RECENT_VIEW_NAME,
            "document-open-recent",
            _("No Recent Games"),
            _("Games which have been recently played will appear here"),
            "document-open-recent"
        );
        add_collection_view (
            _("Unplayed"),
            UNPLAYED_VIEW_NAME,
            "mail-unread",
            _("No Unplayed Games"),
            _("Games which have not yet been played will appear here"),
            "mail-unread" // TODO: Find a suitable icon of the right size
        );

        var header_group = new Hdy.HeaderGroup ();
        header_group.add_header_bar (library_side_panel.header_bar);
        header_group.add_header_bar (header_bar);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 240
        };
        paned.pack1 (library_side_panel, false, false);
        paned.pack2 (library_grid, true, false);

        attach (paned, 0, 0);

        show_all ();

        // TODO: Load last shown view, but default to WelcomeView
        library_stack.set_visible_child_name (Replay.Views.WelcomeView.NAME);
    }

    private void add_collection_view (string display_name, string view_name, string icon_name, string placeholder_title, string placeholder_description, string placeholder_icon_name) {
        var view = new Replay.Views.LibraryView (placeholder_title, placeholder_description, placeholder_icon_name);
        view.game_selected.connect ((game) => {
            on_game_selected (game);
        });
        library_side_panel.add_collection (display_name, view_name, icon_name);
        library_stack.add_named (view, view_name);
    }

    private void add_system_view (string display_name, string view_name, string icon_name) {
        var view = new Replay.Views.LibraryView (_("No Games Available"), _("There are no games in the library that can be played by this system"), icon_name);
        view.game_selected.connect ((game) => {
            on_game_selected (game);
        });
        library_side_panel.add_system (display_name, view_name, icon_name);
        library_stack.add_named (view, view_name);
    }

    private void remove_system_view (string view_name) {
        // TODO: Remove the view from the stack
        // TODO: Remove the item from the side panel
    }

    public void add_game (Replay.Models.Game game, Gee.List<string> core_names) {
        if (game.is_hidden) {
            return;
        }
        if (game.is_favorite) {
            add_game_to_view (game, FAVORITES_VIEW_NAME);
        }
        if (!game.is_played) {
            add_game_to_view (game, UNPLAYED_VIEW_NAME);
        }
        if (game.is_recently_played) {
            add_game_to_view (game, RECENT_VIEW_NAME);
        }
        if (core_names.size > 0) {
            foreach (var core_name in core_names) {
                add_game_to_view (game, core_name);
            }
        } else {
            // TODO: Add to catch-all category
        }
    }

    private void add_game_to_view (Replay.Models.Game game, string view_name) {
        unowned Replay.Views.LibraryView? view = library_stack.get_child_by_name (view_name) as Replay.Views.LibraryView;
        if (view == null) {
            warning ("No view found with name %s", view_name);
            return;
        }
        if (view.add_game (game)) {
            library_side_panel.increment_badge (view_name);
        }
    }

    //  public void set_games (Gee.HashMap<string, Gee.List<Replay.Models.Game>> games_by_system) {
    //      foreach (var entry in games_by_system.entries) {
    //          foreach (var game in entry.value) {
    //              // Don't show hidden games
    //              if (game.is_hidden) {
    //                  continue;
    //              }
    //              if (game.is_favorite) {
    //                  unowned Replay.Views.LibraryView? view = library_stack.get_child_by_name ("favorites") as Replay.Views.LibraryView;
    //                  if (view == null) {
    //                      continue;
    //                  }
    //                  if (view.add_game (game)) {
    //                      library_side_panel.increment_badge ("favorites");
    //                  }
    //              }
    //              if (game.is_unplayed) {
    //                  unowned Replay.Views.LibraryView? view = library_stack.get_child_by_name ("unplayed") as Replay.Views.LibraryView;
    //                  if (view == null) {
    //                      continue;
    //                  }
    //                  if (view.add_game (game)) {
    //                      library_side_panel.increment_badge ("unplayed");
    //                  }
                    
    //              }
    //              if (game.is_recently_played) {
    //                  unowned Replay.Views.LibraryView? view = library_stack.get_child_by_name ("recent") as Replay.Views.LibraryView;
    //                  if (view == null) {
    //                      continue;
    //                  }
    //                  if (view.add_game (game)) {
    //                      library_side_panel.increment_badge ("recent");
    //                  }
    //              }
    //              if (entry.key == "") {
    //                  // TODO: Add to catch-all category
    //              } else {
    //                  unowned Replay.Views.LibraryView? view = library_stack.get_child_by_name (entry.key) as Replay.Views.LibraryView;
    //                  if (view == null) {
    //                      continue;
    //                  }
    //                  if (view.add_game (game)) {
    //                      library_side_panel.increment_badge (entry.key);
    //                  }
    //              }
    //          }
    //      }
    //  }

    public void add_view_for_core (Replay.Models.LibretroCore core) {
        var display_name = core.info.display_name;
        var view_name = core.info.core_name;
        if (library_stack.get_child_by_name (view_name) == null) {
            add_system_view (display_name, view_name, "input-gaming");
        }
    }

    //  public void set_cores (Gee.Collection<Replay.Models.LibretroCore> cores) {
    //      var supported_system_ids = new Gee.ArrayList<string> ();
    //      // Add new cores
    //      foreach (var core in cores) {
    //          var view_name = core.info.system_id;
    //          supported_system_ids.add (view_name);
    //          if (library_stack.get_child_by_name (view_name) == null) {
    //              var display_name = "%s %s".printf (core.info.manufacturer, core.info.system_name);
    //              add_system_view (display_name, view_name, "input-gaming");
    //          }
    //      }
    //      // Remove old cores
    //      foreach (var child in library_stack.get_children ()) {
    //          // Ignore the loading view
    //          //  if ( == Replay.Views.WelcomeView.NAME) {
    //          //      continue;
    //          //  }
    //          //  var library_view = child as Replay.Views.LibraryView;
    //          //  if (!supported_system_ids.contains (library_view.name)) {
    //          //      library_stack.remove (child);
    //          //  }
    //      }
    //  }

    private void on_side_panel_item_selected (Granite.Widgets.SourceList.Item item) {
        var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
        library_stack.set_visible_child_name (side_panel_item.view_name);
    }

    private void on_game_selected (Replay.Models.Game game) {
        game_selected (game);
    }

    public void show_favorites_view () {
        library_stack.set_visible_child_name ("favorites");
    }

    public signal void game_selected (Replay.Models.Game game);

}
