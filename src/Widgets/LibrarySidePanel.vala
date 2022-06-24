/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.LibrarySidePanel : Gtk.Grid {

    public Hdy.HeaderBar header_bar { get; construct; }

    private Granite.Widgets.SourceList source_list;
    private Granite.Widgets.SourceList.ExpandableItem collections_category;
    private Granite.Widgets.SourceList.ExpandableItem systems_category;

    construct {
        unowned Gtk.StyleContext style_context = get_style_context ();
        style_context.add_class (Gtk.STYLE_CLASS_SIDEBAR);

        header_bar = new Hdy.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };
        header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        source_list = new Granite.Widgets.SourceList ();
        source_list.set_filter_func ((item) => {
            // Always show the expandable (category) items
            if (item.parent == source_list.root) {
                return true;
            }
            // Always show all collections items
            if (item.parent == collections_category) {
                return true;
            }
            // Only show platform/system items for which there are games in the library
            return int.parse (item.badge) > 0;
        }, false);
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
        foreach (var item in systems_category.children) {
            var side_panel_item = item as Replay.Widgets.LibrarySidePanelItem;
            if (side_panel_item.view_name == view_name) {
                source_list.selected = side_panel_item;
                return;
            }
        }
    }

    public void add_collection (string display_name, string icon_name, string view_name) {
        collections_category.add (new Replay.Widgets.LibrarySidePanelItem (display_name, icon_name, view_name));
    }

    public void add_system (string display_name, string icon_name, string view_name) {
        systems_category.add (new Replay.Widgets.LibrarySidePanelItem (display_name, icon_name, view_name));
    }

    public void expand_systems_category () {
        systems_category.expand_all ();
    }

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
