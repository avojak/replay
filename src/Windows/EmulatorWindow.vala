/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Windows.EmulatorWindow : Hdy.Window {

    public weak Replay.Application app { get; construct; }

    private Replay.Services.EmulatorWindowActionManager action_manager;
    private Gtk.AccelGroup accel_group;

    public string game_display_name { get; construct; }

    private Replay.Layouts.EmulatorLayout layout;

    public EmulatorWindow (Replay.Application application, string title) {
        Object (
            title: title,
            game_display_name: title,
            application: application,
            app: application,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        accel_group = new Gtk.AccelGroup ();
        add_accel_group (accel_group);
        action_manager = new Replay.Services.EmulatorWindowActionManager (app, this);

        layout = new Replay.Layouts.EmulatorLayout (this, game_display_name);
        layout.pause_button_clicked.connect (() => {
            pause_button_clicked ();
        });
        layout.resume_button_clicked.connect (() => {
            resume_button_clicked ();
        });
        layout.speed_changed.connect ((speed) => {
            speed_changed (speed);
        });
        add (layout);

        // TODO: Somewhere should show which core is being used? Could toggle a little info bar at the bottom to show framerate, core name, etc.

        restore_window_position ();

        this.delete_event.connect (before_destroy);

        show_emulator ();
    }

    private void restore_window_position () {
        move (Replay.Application.settings.emu_pos_x, Replay.Application.settings.emu_pos_y);
        resize (Replay.Application.settings.emu_window_width, Replay.Application.settings.emu_window_height);
        if (Replay.Application.settings.emu_window_fullscreen) {
            maximize ();
        }
    }

    public bool before_destroy () {
        update_position_settings ();
        destroy ();
        return true;
    }

    private void update_position_settings () {
        // Only save the position and size state when the window is not maximized,
        // otherwise it can mess up the preference values
        if (!is_maximized) {
            int width, height, x, y;

            get_size (out width, out height);
            get_position (out x, out y);

            Replay.Application.settings.emu_pos_x = x;
            Replay.Application.settings.emu_pos_y = y;
            Replay.Application.settings.emu_window_width = width;
            Replay.Application.settings.emu_window_height = height;
        }
    }

    private void show_emulator () {
        show_all ();
        present ();
    }

    public unowned Retro.CoreView get_core_view () {
        return layout.view;
    }

    public void show_pause_button () {
        layout.show_pause_button ();
    }

    public void show_resume_button () {
        layout.show_resume_button ();
    }

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();
    public signal void speed_changed (double speed);

}
