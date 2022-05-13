/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.GameGrid : Gtk.Grid {

    private static Gtk.CssProvider provider;

    public Gtk.FlowBox flow_box { get; construct; }
    //  private Replay.Widgets.GameGridDetailsPanel game_details_panel;

    private Replay.Models.Functions.LibraryItemFilterFunction? filter_func;

    private Granite.Widgets.AlertView alert_view;
    private Gtk.Stack stack;

    public GameGrid () {
        Object (
            expand: true
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/AlertView.css");
    }

    construct {
        flow_box = new Gtk.FlowBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE,
            homogeneous = true,
            expand = true,
            margin = 12,
            valign = Gtk.Align.START
        };
        flow_box.child_activated.connect (on_item_selected);
        //  flow_box.button_press_event.connect (launch_game);
        flow_box.button_press_event.connect (show_context_menu);
        //  flow_box.button_press_event.connect (show_details_panel);

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            expand = true
        };
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (flow_box);

        //  var event_box = new Gtk.EventBox ();
        //  event_box.add (scrolled_window);
        //  event_box.set_events (Gdk.EventMask.ENTER_NOTIFY_MASK);
        //  event_box.set_events (Gdk.EventMask.LEAVE_NOTIFY_MASK);

        //  event_box.enter_notify_event.connect (() => {
        //      debug ("enter grid");
        //  });
        //  event_box.leave_notify_event.connect (() => {
        //      debug ("leave grid");
        //  });

        //  game_details_panel = new Replay.Widgets.GameGridDetailsPanel ();
        //  revealer = new Gtk.Revealer () {
        //      transition_type = Gtk.RevealerTransitionType.SLIDE_UP
        //  };
        //  revealer.add (game_details_panel);

        alert_view = new Granite.Widgets.AlertView ("", "", "");
        alert_view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        stack = new Gtk.Stack () {
            expand = true
        };
        stack.add_named (scrolled_window, "scrolled-window");
        stack.add_named (alert_view, "alert-view");

        var grid = new Gtk.Grid () {
            expand = true
        };
        grid.attach (stack, 0, 0);

        add (grid);
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
            var run_item = create_image_menu_item (_("Play"), "");
            run_item.activate.connect (() => {
                on_item_run_selected (library_item);
            });
            var run_with_item = create_image_menu_item (_("Play with"), "");
            var run_with_submenu = new Gtk.Menu ();
            foreach (var core in Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (library_item.game.rom_path))) {
                var item = new Gtk.MenuItem.with_label (core.info.core_name);
                item.activate.connect (() => {
                    // TODO: Pass specific core
                    on_item_run_selected (library_item);
                });
                run_with_submenu.add (item);
            }
            run_with_item.submenu = run_with_submenu;
            var played_item = create_image_menu_item (_("Mark as Played"), "mail-read");
            played_item.activate.connect (() => {
                item_marked_played (library_item);
            });
            var unplayed_item = create_image_menu_item (_("Mark as Unplayed"), "mail-unread");
            unplayed_item.activate.connect (() => {
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
            menu.add (run_with_item);
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

    //  private bool show_details_panel (Gdk.EventButton event) {
    //      if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == Gdk.BUTTON_PRIMARY) {
    //          unowned Gtk.FlowBoxChild? child = flow_box.get_child_at_pos ((int) event.x, (int) event.y);
    //          if (child == null) {
    //              //  revealer.set_reveal_child (false);
    //              //  flow_box.unselect_all ();
    //              return false;
    //          }
    //          unowned var library_item = child as Replay.Widgets.LibraryItem;
    //          game_details_panel.update_title (library_item.game.display_name);
    //          revealer.set_reveal_child (true);
    //          return true;
    //      }
    //      return false;
    //  }

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

    private void on_item_selected (Gtk.FlowBoxChild child) {
        item_selected (child as Replay.Widgets.LibraryItem);
    }

    private void on_item_run_selected (Gtk.FlowBoxChild child) {
        unowned var library_item = child as Replay.Widgets.LibraryItem;
        item_run (library_item);
        item_marked_played (library_item);
    }

    public void set_filter_func (Replay.Models.Functions.LibraryItemFilterFunction? filter_func) {
        this.filter_func = filter_func;
        if (filter_func == null) {
            flow_box.set_filter_func (null);
            invalidate_filter ();
        } else {
            alert_view.title = filter_func.placeholder_title;
            alert_view.description = filter_func.placeholder_description;
            alert_view.icon_name = filter_func.placeholder_icon_name;
            flow_box.set_filter_func ((child) => {
                return filter_func.filter (child as Replay.Widgets.LibraryItem);
            });
            invalidate_filter ();
        }
    }

    public void set_sort_func (Replay.Models.Functions.LibraryItemSortFunction? sort_func) {
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
        update_visible_stack_child ();
    }

    public void invalidate_sort () {
        flow_box.invalidate_sort ();
    }

    private void update_visible_stack_child () {
        //  Idle.add (() => {
            if (count_visible_children (filter_func) > 0) {
                stack.set_visible_child_name ("scrolled-window");
            } else {
                stack.set_visible_child_name ("alert-view");
            }
            //  return false;
        //  });
    }

    public int count_visible_children (Replay.Models.Functions.LibraryItemFilterFunction? filter_func) {
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

    public signal void item_selected (Replay.Widgets.LibraryItem library_item);
    public signal void item_run (Replay.Widgets.LibraryItem library_item);
    public signal void item_added_to_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_removed_from_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_played (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_unplayed (Replay.Widgets.LibraryItem library_item);

}
