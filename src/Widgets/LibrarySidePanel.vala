/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.LibrarySidePanel : Gtk.Grid {

    public Hdy.HeaderBar header_bar { get; construct; }

    private Granite.Widgets.SourceList source_list;
    private Granite.Widgets.SourceList.ExpandableItem collections_category;
    private Granite.Widgets.SourceList.ExpandableItem systems_category;
    //  private Granite.Widgets.SourceList.Item favorites_item;
    //  private Granite.Widgets.SourceList.Item recent_item;
    //  private Granite.Widgets.SourceList.Item unplayed_item;

    construct {
        unowned Gtk.StyleContext style_context = get_style_context ();
        style_context.add_class (Gtk.STYLE_CLASS_SIDEBAR);

        header_bar = new Hdy.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };
        header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        source_list = new Granite.Widgets.SourceList ();
        source_list.item_selected.connect ((item) => {
            if (item == null) {
                return;
            }
            item_selected (item as Replay.Widgets.LibrarySidePanelItem);
        });

        collections_category = new Granite.Widgets.SourceList.ExpandableItem (_("Library")) {
            selectable = false,
            expanded = true
        };
        //  favorites_item = new Granite.Widgets.SourceList.Item (_("Favorites")) {
        //      icon = new GLib.ThemedIcon ("starred")
        //  };
        //  recent_item = new Granite.Widgets.SourceList.Item (_("Recently Played")) {
        //      icon = new GLib.ThemedIcon ("document-open-recent")
        //  };
        //  unplayed_item = new Granite.Widgets.SourceList.Item (_("Unplayed")) {
        //      icon = new GLib.ThemedIcon ("mail-unread")
        //  };
        //  collections_category.add (favorites_item);
        //  collections_category.add (recent_item);
        //  collections_category.add (unplayed_item);

        systems_category = new Granite.Widgets.SourceList.ExpandableItem (_("Systems")) {
            selectable = false,
            expanded = true
        };

        source_list.root.add (collections_category);
        source_list.root.add (systems_category);

        attach (header_bar, 0, 0);
        attach (source_list, 0, 1);
    }

    public void select_view (string view_name) {
        foreach (var item in collections_category.children) {
            var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
            if (side_panel_item.view_name == view_name) {
                source_list.selected = side_panel_item;
                return;
            }
        }
    }

    public void add_collection (string display_name, string icon_name, string view_name) {
        var item = new Replay.Widgets.LibrarySidePanelItem (display_name, icon_name, view_name);
        //  item.filter_func = filter_func;
        collections_category.add (item);
    }

    //  public void add_system (string display_name, string view_name, string icon_name) {
    //      systems_category.add (new Replay.Widgets.LibrarySidePanelItem (display_name, view_name) {
    //          icon = new GLib.ThemedIcon (icon_name)
    //      });
    //  }

    //  public void increment_badge (string view_name) {
    //      foreach (var item in collections_category.children) {
    //          var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
    //          if (side_panel_item.view_name == view_name) {
    //              side_panel_item.badge = (int.parse (side_panel_item.badge) + 1).to_string ();
    //          }
    //      }
    //      foreach (var item in systems_category.children) {
    //          var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
    //          if (side_panel_item.view_name == view_name) {
    //              side_panel_item.badge = (int.parse (side_panel_item.badge) + 1).to_string ();
    //          }
    //      }
    //  }

    //  public void decrement_badge (string view_name) {
    //      foreach (var item in collections_category.children) {
    //          var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
    //          if (side_panel_item.view_name == view_name) {
    //              side_panel_item.badge = (int.parse (side_panel_item.badge) - 1).to_string ();
    //          }
    //      }
    //      foreach (var item in systems_category.children) {
    //          var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
    //          if (side_panel_item.view_name == view_name) {
    //              side_panel_item.badge = (int.parse (side_panel_item.badge) - 1).to_string ();
    //          }
    //      }
    //  }

    public Gee.Collection<Replay.Widgets.LibrarySidePanelItem> get_items () {
        var items = new Gee.ArrayList<Replay.Widgets.LibrarySidePanelItem> ();
        foreach (var item in collections_category.children) {
            items.add (item as Replay.Widgets.LibrarySidePanelItem);
        }
        foreach (var item in systems_category.children) {
            items.add (item as Replay.Widgets.LibrarySidePanelItem);
        }
        return items;
    }

    public void set_enabled (bool enabled) {
        source_list.sensitive = enabled;
    }

    public void select_none () {
        source_list.selected = null;
    }

    public signal void item_selected (Replay.Widgets.LibrarySidePanelItem item);

}
