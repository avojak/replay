/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.MediaItem : Gtk.FlowBoxChild {

    public GLib.File image_file { get; construct; }

    public MediaItem.for_image_file (GLib.File image_file) {
        Object (
            image_file: image_file
        );
    }

    construct {
        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin = 8
        };
        try {
            grid.add (new Gtk.Image.from_pixbuf (new Gdk.Pixbuf.from_file_at_size (image_file.get_path (), 100, 100)) {
                margin = 16
            });
        } catch (GLib.Error e) {
            warning (e.message);
            grid.add (new Gtk.Image () {
                gicon = new ThemedIcon ("image-missing"),
                pixel_size = 128
            });
        }

        child = grid;

        show_all ();
    }

}
