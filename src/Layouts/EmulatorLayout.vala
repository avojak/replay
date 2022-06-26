/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Layouts.EmulatorLayout : Gtk.Grid {

    public unowned Replay.Windows.EmulatorWindow window { get; construct; }
    public Retro.CoreView view { get; construct; }
    public string title { get; construct; }

    private Replay.Widgets.EmulatorHeaderBar header_bar;

    public EmulatorLayout (Replay.Windows.EmulatorWindow window, string title) {
        Object (
            window: window,
            title: title
        );
    }

    construct {
        header_bar = new Replay.Widgets.EmulatorHeaderBar (title);
        header_bar.pause_button_clicked.connect (() => {
            pause_button_clicked ();
        });
        header_bar.resume_button_clicked.connect (() => {
            resume_button_clicked ();
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

        attach (header_bar, 0, 0);
        attach (view, 0, 1);

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

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();
    public signal void speed_changed (double speed);

}
