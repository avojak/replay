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

public class Replay.Widgets.GameGrid : Gtk.Grid {

    public Gtk.FlowBox flow_box { get; construct; }

    public GameGrid () {
        Object (
            expand: true
        );
    }

    construct {
        flow_box = new Gtk.FlowBox () {
            activate_on_single_click = false,
            selection_mode = Gtk.SelectionMode.SINGLE,
            homogeneous = true,
            expand = true,
            margin = 12,
            valign = Gtk.Align.START
        };
        flow_box.child_activated.connect (on_item_activated);
        flow_box.button_press_event.connect (show_context_menu);

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            expand = true
        };
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (flow_box);

        add (scrolled_window);
    }

    private bool show_context_menu (Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == Gdk.BUTTON_SECONDARY) {
            unowned Gtk.FlowBoxChild? child = flow_box.get_child_at_pos ((int) event.x, (int) event.y);
            if (child == null) {
                return false;
            }
            flow_box.select_child (child); // Makes it clear which item was clicked
            unowned var library_item = child as Replay.Widgets.LibraryItem;
            var menu = new Gtk.Menu ();
            var run_item = create_image_menu_item (_("Run"), "media-playback-start");
            run_item.activate.connect (() => {
                on_item_activated (library_item);
            });
            var played_item = create_image_menu_item (_("Mark as Played"), "mail-read");
            played_item.activate.connect (() => {
                library_item.set_played (true);
                item_marked_played (library_item);
            });
            var unplayed_item = create_image_menu_item (_("Mark as Unplayed"), "mail-unread");
            unplayed_item.activate.connect (() => {
                library_item.set_played (false);
                item_marked_unplayed (library_item);
            });
            var favorite_item = create_image_menu_item (_("Add to Favorites"), "starred");
            favorite_item.activate.connect (() => {
                item_added_to_favorites (library_item);
            });
            var unfavorite_item = create_image_menu_item (_("Remove from Favorites"), "non-starred");
            unfavorite_item.activate.connect (() => {
                item_removed_from_favorites (library_item);
            });
            //  var rename_item = create_image_menu_item (_("Rename…"), "edit");
            //  rename_item.activate.connect (() => {
            //      // TODO
            //  });
            var properties_item = create_image_menu_item (_("Properties…"), "");
            properties_item.activate.connect (() => {
                // TODO
            });
            var delete_item = create_image_menu_item (_("Delete"), "edit-delete");
            delete_item.activate.connect (() => {
                // TODO
            });
            // TODO: Support adding item to add to a custom category
            menu.add (run_item);
            menu.add (new Gtk.SeparatorMenuItem ());
            menu.add (library_item.game.is_favorite ? unfavorite_item : favorite_item);
            menu.add (library_item.game.is_played ? unplayed_item : played_item);
            menu.add (new Gtk.SeparatorMenuItem ());
            menu.add (properties_item);
            //  menu.add (new Gtk.SeparatorMenuItem ());
            //  menu.add (delete_item);
            menu.attach_to_widget (child, null);
            menu.show_all ();
            menu.popup_at_pointer (event);
            return true;
        }
        return false;
    }

    private Gtk.MenuItem create_image_menu_item (string str, string icon_name) {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.MENU) {
            margin_left = 6
        };
        var label = new Gtk.Label (str);
        label.set_xalign (0);

        box.pack_start (icon, false, false, 0);
        box.pack_end (label, true, true, 0);

        var item = new Gtk.MenuItem ();
        item.add (box);

        return item;
    }

    private void on_item_activated (Gtk.FlowBoxChild child) {
        unowned var library_item = child as Replay.Widgets.LibraryItem;
        library_item.set_played (true);
        item_run (library_item);
        item_marked_played (library_item);
    }

    public void set_filter_func (Replay.Models.LibraryItemFilterFunction? filter_func) {
        if (filter_func == null) {
            flow_box.set_filter_func (null);
        } else {
            flow_box.set_filter_func ((child) => {
                return filter_func.filter (child as Replay.Widgets.LibraryItem);
            });
        }
    }

    public void set_sort_func (Replay.Models.LibraryItemSortFunction? sort_func) {
        if (sort_func == null) {
            flow_box.set_sort_func (null);
        } else {
            flow_box.set_sort_func ((child1, child2) => {
                return sort_func.sort (child1 as Replay.Widgets.LibraryItem, child2 as Replay.Widgets.LibraryItem);
            });
        }
    }

    public void invalidate_filter () {
        flow_box.invalidate_filter ();
    }

    public void invalidate_sort () {
        flow_box.invalidate_sort ();
    }

    public int count_visible_children (Replay.Models.LibraryItemFilterFunction? filter_func) {
        int num_visible = 0;
        flow_box.foreach ((widget) => {
            if (filter_func == null || filter_func.filter (widget as Replay.Widgets.LibraryItem)) {
                num_visible++;
            }
        });
        return num_visible;
    }

    public int get_visible_children () {
        int num_visible = 0;
        foreach (var child in flow_box.get_children ()) {
            if (child.get_mapped ()) {
                num_visible++;
            }
        }
        return num_visible;
    }

    public bool add_game (Replay.Models.Game game) {
        //  if (games.contains (game)) {
        //      return false;
        //  }
        var game_item = new Replay.Widgets.LibraryItem.for_game (game);
        flow_box.add (game_item);
        //  games.add (game);
        return true;
    }

    public bool remove_game (Replay.Models.Game game) {
        // TODO
        return true;
    }

    //  public delegate bool FilterFunction (Replay.Widgets.LibraryItem library_item);

    public signal void item_run (Replay.Widgets.LibraryItem library_item);
    public signal void item_added_to_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_removed_from_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_played (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_unplayed (Replay.Widgets.LibraryItem library_item);

}