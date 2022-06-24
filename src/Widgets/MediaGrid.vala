/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.MediaGrid : Gtk.Grid {

    public Gtk.FlowBox flow_box { get; construct; }
    private int num_children = 0;

    public MediaGrid () {
        Object (
            hexpand: true,
            vexpand: false
        );
    }

    construct {
        flow_box = new Gtk.FlowBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE,
            homogeneous = true,
            expand = true,
            margin = 12,
            valign = Gtk.Align.START,
            min_children_per_line = 1
        };
        flow_box.child_activated.connect (on_image_selected);
        add (flow_box);
    }

    public void add_media (GLib.File image_file) {
        flow_box.add (new Replay.Widgets.MediaItem.for_image_file (image_file));
        num_children++;
        flow_box.min_children_per_line = num_children;
    }

    private void on_image_selected (Gtk.FlowBoxChild child) {
        var image_file = ((Replay.Widgets.MediaItem) child).image_file;
        new Replay.Widgets.Dialogs.MediaDialog.for_image_file (Replay.Application.get_instance (), Replay.Application.get_instance ().library_window, image_file);
    }

}
