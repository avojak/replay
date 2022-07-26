/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.InterfaceSettingsView : Replay.Views.Settings.AbstractSettingsView {

    private Gee.Map<int, Retro.VideoFilter> video_filters;

    private Gtk.ComboBox video_filter_combo;
    private Gtk.SpinButton screen_size_width_entry;
    private Gtk.SpinButton screen_size_height_entry;

    enum VideoFilterColumn {
        VIDEO_FILTER
    }

    construct {
        var emulator_windows_header_label = new Granite.HeaderLabel (_("Emulator Windows"));

        var video_filter_label = new Gtk.Label (_("Default video filter:")) {
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
            //  hexpand = true
            halign = Gtk.Align.START
        };
        var video_filter_cell = new Gtk.CellRendererText ();
        video_filter_combo.pack_start (video_filter_cell, false);
        video_filter_combo.set_attributes (video_filter_cell, "text", 0);
        video_filter_combo.changed.connect (() => {
            var short_name = Replay.Models.VideoFilterMapping.get_short_name (video_filters.get (video_filter_combo.get_active ()));
            Replay.Application.settings.set_string ("emu-default-filter", short_name);
        });

        var fullscreen_label = new Gtk.Label (_("Open in fullscreen:")) {
            halign = Gtk.Align.END
        };

        var fullscreen_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Replay.Application.settings.bind ("emu-window-fullscreen", fullscreen_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var content_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            expand = true,
            row_spacing = 6,
            column_spacing = 12
        };
        content_grid.attach (emulator_windows_header_label, 0, 0, 2);
        content_grid.attach (video_filter_label, 0, 1);
        content_grid.attach (video_filter_combo, 1, 1);
        content_grid.attach (fullscreen_label, 0, 2);
        content_grid.attach (fullscreen_switch, 1, 2);

        add (content_grid);

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
            //  hexpand = true
            halign = Gtk.Align.START
        };
        button.set_value (default_value);
        return button;
    }

    private void load_settings () {
        var default_video_filter = Replay.Models.VideoFilterMapping.from_short_name (Replay.Application.settings.emu_default_filter);
        switch (default_video_filter) {
            case Retro.VideoFilter.SHARP:
                video_filter_combo.set_active (0);
                return;
            case Retro.VideoFilter.SMOOTH:
                video_filter_combo.set_active (1);
                return;
            case Retro.VideoFilter.CRT:
                video_filter_combo.set_active (2);
                return;
            default:
                assert_not_reached ();
        }
    }

}
