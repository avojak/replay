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

 public class Replay.Views.Settings.DisplaySettingsView : Granite.SimpleSettingsPage {

    private Gee.Map<int, Retro.VideoFilter> video_filters;

    private Gtk.ComboBox video_filter_combo;
    private Gtk.SpinButton screen_size_width_entry;
    private Gtk.SpinButton screen_size_height_entry;

    enum VideoFilterColumn {
        VIDEO_FILTER
    }

    public DisplaySettingsView () {
        Object (
            activatable: false,
            description: "Preferences for emulator displays",
            header: null,
            icon_name: "preferences-desktop-display",
            title: "Displays"
        );
    }

    construct {
        // TODO:
        // [x] Video filter
        // [x] Open fullscreen
        // [x] Screen size (should this just be saved from previous session...? Or maybe do it per-system? Or on an aspect ratio basis?)
        // [ ] Pause on focus lost (maybe this is a behavior setting?)

        var video_filter_label = new Gtk.Label (_("Default Video Filter:")) {
            halign = Gtk.Align.END
        };

        var video_filter_list_store = new Gtk.ListStore (1, typeof (string));
        video_filters = new Gee.HashMap<int, Retro.VideoFilter> ();
        var video_filters_display_strings = new Gee.HashMap<int, string> ();
        video_filters.set (0, Retro.VideoFilter.SHARP);
        video_filters_display_strings.set (0, "%s (%s)".printf (Replay.Models.VideoFilterMapping.get_display_strings ().get (Retro.VideoFilter.SHARP), Replay.Models.VideoFilterMapping.get_descriptions ().get (Retro.VideoFilter.SHARP)));
        video_filters.set (1, Retro.VideoFilter.SMOOTH);
        video_filters_display_strings.set (1, "%s (%s)".printf (Replay.Models.VideoFilterMapping.get_display_strings ().get (Retro.VideoFilter.SMOOTH), Replay.Models.VideoFilterMapping.get_descriptions ().get (Retro.VideoFilter.SMOOTH)));
        video_filters.set (2, Retro.VideoFilter.CRT);
        video_filters_display_strings.set (2, "%s (%s)".printf (Replay.Models.VideoFilterMapping.get_display_strings ().get (Retro.VideoFilter.CRT), Replay.Models.VideoFilterMapping.get_descriptions ().get (Retro.VideoFilter.CRT)));
        for (int i = 0; i < video_filters_display_strings.size; i++) {
            Gtk.TreeIter iter;
            video_filter_list_store.append (out iter);
            video_filter_list_store.set (iter, VideoFilterColumn.VIDEO_FILTER, video_filters_display_strings[i]);
        }

        video_filter_combo = new Gtk.ComboBox.with_model (video_filter_list_store) {
            hexpand = true
        };
        var video_filter_cell = new Gtk.CellRendererText ();
        video_filter_combo.pack_start (video_filter_cell, false);
        video_filter_combo.set_attributes (video_filter_cell, "text", 0);
        video_filter_combo.changed.connect (() => {
            // TODO
        });

        var screen_size_label = new Gtk.Label (_("Default Size:")) {
            halign = Gtk.Align.END
        };

        var screen_size_grid = new Gtk.Grid ();
        var workarea = Gdk.Display.get_default ().get_primary_monitor ().workarea;
        screen_size_width_entry = create_spin_button (workarea.width, 500);
        screen_size_height_entry = create_spin_button (workarea.height, 500);
        screen_size_grid.attach (create_spin_button_label (_("W")), 0, 0);
        screen_size_grid.attach (screen_size_width_entry, 1, 0);
        screen_size_grid.attach (create_spin_button_label (_("H")), 2, 0);
        screen_size_grid.attach (screen_size_height_entry, 3, 0);

        var fullscreen_label = new Gtk.Label (_("Open in Fullscreen:")) {
            halign = Gtk.Align.END
        };

        var fullscreen_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Replay.Application.settings.bind ("emu-window-fullscreen", fullscreen_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        content_area.attach (video_filter_label, 0, 0);
        content_area.attach (video_filter_combo, 1, 0);
        content_area.attach (screen_size_label, 0, 1);
        content_area.attach (screen_size_grid, 1, 1);
        content_area.attach (fullscreen_label, 0, 2);
        content_area.attach (fullscreen_switch, 1, 2);

        var reset_button = new Gtk.Button.with_label (_("Restore Default Settings"));

        action_area.add (reset_button);
        action_area.set_child_secondary (reset_button, true);

        reset_button.clicked.connect (() => {
            // TODO
        });

        load_settings ();
    }

    private Gtk.Label create_spin_button_label (string str) {
        var label = new Gtk.Label (str) {
            margin_right = 8,
            margin_left = 8
        };
        label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        return label;
    }

    private Gtk.SpinButton create_spin_button (double max_value, double default_value) {
        var button = new Gtk.SpinButton.with_range (0, max_value, 1) {
            secondary_icon_name = "input-pixel-symbolic",
            secondary_icon_activatable = false,
            secondary_icon_sensitive = false,
            hexpand = true
        };
        button.set_value (default_value);
        return button;
    }

    private void load_settings () {
        // TODO
        video_filter_combo.set_active (0);
    }

}
