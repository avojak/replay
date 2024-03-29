/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Layouts.EmulatorLayout : Gtk.Grid {

    private static Gtk.CssProvider provider;

    public unowned Replay.Windows.EmulatorWindow window { get; construct; }
    public Retro.CoreView view { get; construct; }
    public string title { get; construct; }

    private Replay.Widgets.EmulatorHeaderBar header_bar;
    private Granite.Widgets.Toast device_toast;
    private Gtk.Stack stack;
    private Gtk.Grid preview;
    private Gtk.Image preview_image;
    private Gtk.ActionBar action_bar;
    private Gtk.Label core_name_label;
    private Gtk.Label input_device_label;
    private Gtk.Label fps_label;

    public EmulatorLayout (Replay.Windows.EmulatorWindow window, string title) {
        Object (
            window: window,
            title: title
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/SaveStatePreview.css");
    }

    construct {
        header_bar = new Replay.Widgets.EmulatorHeaderBar (window, title);
        header_bar.pause_button_clicked.connect (() => {
            pause_button_clicked ();
        });
        header_bar.resume_button_clicked.connect (() => {
            resume_button_clicked ();
        });
        header_bar.restart_button_clicked.connect (() => {
            restart_button_clicked ();
        });
        header_bar.video_filter_changed.connect ((filter) => {
            view.set_filter (filter);
        });
        header_bar.speed_changed.connect ((speed) => {
            speed_changed (speed);
        });

        view = new Retro.CoreView () {
            expand = true
        };
        var video_filter = Replay.Models.VideoFilterMapping.from_short_name (Replay.Application.settings.emu_default_filter);
        view.set_filter (video_filter);
        header_bar.set_filter_mode (video_filter);

        // Prevent loss of focus when using arrow keys within a game
        view.key_press_event.connect (() => {
            return true;
        });
        view.show ();

        preview_image = new Gtk.Image () {
            expand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        preview = new Gtk.Grid () {
            expand = true
        };
        preview.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        preview.get_style_context ().add_class ("preview");
        preview.attach (preview_image, 0, 0);

        stack = new Gtk.Stack ();
        stack.add (preview);
        stack.add (view);

        device_toast = new Granite.Widgets.Toast ("");

        var overlay = new Gtk.Overlay ();
        overlay.add (stack);
        overlay.add_overlay (device_toast);

        core_name_label = new Gtk.Label (null);
        input_device_label = new Gtk.Label (null);
        fps_label = new Gtk.Label (null);

        action_bar = new Gtk.ActionBar ();
        action_bar.pack_start (new Gtk.Image () {
            gicon = new ThemedIcon ("cpu-symbolic"),
            pixel_size = 16
        });
        action_bar.pack_start (core_name_label);
        action_bar.pack_start (new Gtk.Image () {
            gicon = new ThemedIcon ("input-gaming-symbolic"),
            pixel_size = 16,
            margin_left = 16
        });
        action_bar.pack_start (input_device_label);
        action_bar.pack_end (fps_label);

        attach (header_bar, 0, 0);
        attach (overlay, 0, 1);
        attach (action_bar, 0, 2);

        show_all ();

        view.grab_focus ();
    }

    public void show_pause_button () {
        header_bar.set_resume_button_visible (false);
        header_bar.set_pause_button_visible (true);
    }

    public void show_resume_button () {
        header_bar.set_pause_button_visible (false);
        header_bar.set_resume_button_visible (true);
    }

    public void set_core_name (string core_name) {
        core_name_label.set_text (core_name);
    }

    public void update_fps (double fps) {
        fps_label.set_text ("%.2f FPS".printf (fps));
    }

    public void update_input_device (string device_name) {
        input_device_label.set_text (device_name);
    }

    public void notify_device_connected (string device_name) {
        device_toast.title = _(@"$device_name connected");
        device_toast.send_notification ();
    }

    public void notify_device_disconnected (string device_name) {
        device_toast.title = _(@"$device_name disconnected");
        device_toast.send_notification ();
    }

    public void toggle_statsbar () {
        action_bar.visible = !action_bar.visible;
    }

    public void show_preview (GLib.File image_file) {
        // This is a bit of a hack because I couldn't get the RetroGTK set_pixbuf to work
        var width = view.get_allocated_width ();
        var height = view.get_allocated_height ();
        try {
            var pixbuf = new Gdk.Pixbuf.from_file_at_scale (image_file.get_path (), width, height, true);
            preview_image.set_from_pixbuf (pixbuf);
        } catch (GLib.Error e) {
            warning (e.message);
        }
        stack.set_visible_child (preview);
    }

    public void show_emulator () {
        stack.set_visible_child (view);
        // Make sure that if the user is using the keyboard, it'll be recognized
        // immediately as input without having to click the view
        view.grab_focus ();
    }

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();
    public signal void restart_button_clicked ();
    public signal void speed_changed (double speed);

}
