/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Windows.EmulatorWindow : Hdy.Window {

    public string game_display_name { get; construct; }

    private Replay.Layouts.EmulatorLayout layout;

    public EmulatorWindow (Replay.Application application, string title) {
        Object (
            title: title,
            game_display_name: title,
            application: application,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        layout = new Replay.Layouts.EmulatorLayout (this, game_display_name);
        layout.pause_button_clicked.connect (() => {
            pause_button_clicked ();
        });
        layout.resume_button_clicked.connect (() => {
            resume_button_clicked ();
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
    }

    public bool before_destroy () {
        update_position_settings ();
        destroy ();
        return true;
    }

    private void update_position_settings () {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        Replay.Application.settings.emu_pos_x = x;
        Replay.Application.settings.emu_pos_y = y;
        Replay.Application.settings.emu_window_width = width;
        Replay.Application.settings.emu_window_height = height;
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

}
