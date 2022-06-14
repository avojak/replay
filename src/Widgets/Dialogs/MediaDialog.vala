/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.Dialogs.MediaDialog : Hdy.Window {

    private const int IMAGE_SIZE = 500;

    public GLib.File image_file { get; construct; }

    public MediaDialog.for_image_file (Replay.Application application, Replay.Windows.LibraryWindow library_window, GLib.File image_file) {
        Object (
            title: Constants.APP_NAME,
            application: application,
            border_width: 0,
            resizable: false,
            transient_for: library_window,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
            image_file: image_file
        );
    }

    construct {
        var grid = new Gtk.Grid ();
        try {
            grid.add (new Gtk.Image.from_pixbuf (new Gdk.Pixbuf.from_file_at_scale (image_file.get_path (), IMAGE_SIZE, IMAGE_SIZE, true)));
        } catch (GLib.Error e) {
            warning (e.message);
            return;
        }

        add (grid);

        // Close the window by clicking anywhere, changing focus, or pressing the Escape key
        focus_out_event.connect (() => {
            close ();
        });
        button_press_event.connect (() => {
            close ();
        });
        key_press_event.connect ((event) => {
            if (event.keyval == Gdk.Key.Escape) {
                close ();
            }
        });

        // Center the window on the parent, since the window_position property doesn't seem to be working
        int parent_x, parent_y, parent_width, parent_height;
        transient_for.get_position (out parent_x, out parent_y);
        transient_for.get_size (out parent_width, out parent_height);
        move (parent_x + (parent_width / 2) - (IMAGE_SIZE / 2), parent_y + (parent_height / 2) - (IMAGE_SIZE / 2));

        show_all ();
    }

}
