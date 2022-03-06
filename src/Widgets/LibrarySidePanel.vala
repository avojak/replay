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
            item_selected (item);
        });

        collections_category = new Granite.Widgets.SourceList.ExpandableItem (_("Game Collections")) {
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

    public void add_collection (string display_name, string view_name, string icon_name) {
        collections_category.add (new Replay.Widgets.LibrarySidePanelItem (display_name, view_name) {
            icon = new GLib.ThemedIcon (icon_name)
        });
    }

    public void add_system (string display_name, string view_name, string icon_name) {
        systems_category.add (new Replay.Widgets.LibrarySidePanelItem (display_name, view_name) {
            icon = new GLib.ThemedIcon (icon_name)
        });
    }

    public void increment_badge (string view_name) {
        foreach (var item in collections_category.children) {
            var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
            if (side_panel_item.view_name == view_name) {
                side_panel_item.badge = (int.parse (side_panel_item.badge) + 1).to_string ();
            }
        }
        foreach (var item in systems_category.children) {
            var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
            if (side_panel_item.view_name == view_name) {
                side_panel_item.badge = (int.parse (side_panel_item.badge) + 1).to_string ();
            }
        }
    }

    public void decrement_badge (string view_name) {
        foreach (var item in collections_category.children) {
            var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
            if (side_panel_item.view_name == view_name) {
                side_panel_item.badge = (int.parse (side_panel_item.badge) - 1).to_string ();
            }
        }
        foreach (var item in systems_category.children) {
            var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
            if (side_panel_item.view_name == view_name) {
                side_panel_item.badge = (int.parse (side_panel_item.badge) - 1).to_string ();
            }
        }
    }

    public signal void item_selected (Granite.Widgets.SourceList.Item item);

}
