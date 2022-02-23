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
    private Granite.Widgets.SourceList.ExpandableItem favorites_category;
    private Granite.Widgets.SourceList.ExpandableItem recent_category;
    private Granite.Widgets.SourceList.ExpandableItem unplayed_category;
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
        
        collections_category = new Granite.Widgets.SourceList.ExpandableItem (_("Game Collections")) {
            selectable = false,
            expanded = true
        };
        favorites_category = new Granite.Widgets.SourceList.ExpandableItem (_("Favorites")) {
            icon = new GLib.ThemedIcon ("starred")
        };
        recent_category = new Granite.Widgets.SourceList.ExpandableItem (_("Recently Played")) {
            icon = new GLib.ThemedIcon ("document-open-recent")
        };
        unplayed_category = new Granite.Widgets.SourceList.ExpandableItem (_("Unplayed")) {
            icon = new GLib.ThemedIcon ("mail-unread")
        };
        collections_category.add (favorites_category);
        collections_category.add (recent_category);
        collections_category.add (unplayed_category);

        systems_category = new Granite.Widgets.SourceList.ExpandableItem (_("Systems"));

        source_list.root.add (collections_category);
        source_list.root.add (systems_category);

        attach (header_bar, 0, 0);
        attach (source_list, 0, 1);
    }

    public void add_system (string display_name, string id) {
        var item = new Granite.Widgets.SourceList.Item (display_name);
        systems_category.add (item);
    }

}