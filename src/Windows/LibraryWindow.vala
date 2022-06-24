/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Windows.LibraryWindow : Hdy.Window {

    public weak Replay.Application app { get; construct; }

    private Replay.Services.LibraryWindowActionManager action_manager;
    private Gtk.AccelGroup accel_group;

    private Replay.Widgets.Dialogs.PreferencesDialog? preferences_dialog = null;
    private Replay.Widgets.Dialogs.AboutDialog? about_dialog = null;

    private Replay.Views.LibraryView view;

    public LibraryWindow (Replay.Application application) {
        Object (
            title: Constants.APP_NAME,
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
        action_manager = new Replay.Services.LibraryWindowActionManager (app, this);

        view = new Replay.Views.LibraryView ();
        view.game_selected.connect (launch_game);

        add (view);

        restore_window_position ();

        this.destroy.connect (() => {
            // Do stuff before closing the library
            //  GLib.Process.exit (0);
        });
        this.delete_event.connect (before_destroy);

        show_app ();
    }

    private void restore_window_position () {
        move (Replay.Application.settings.pos_x, Replay.Application.settings.pos_y);
        resize (Replay.Application.settings.window_width, Replay.Application.settings.window_height);
    }

    private void show_app () {
        show_all ();
        present ();
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

        Replay.Application.settings.set_int ("pos-x", x);
        Replay.Application.settings.set_int ("pos-y", y);
        Replay.Application.settings.set_int ("window-width", width);
        Replay.Application.settings.set_int ("window-height", height);
    }

    public void reload_library () {
        debug ("Reloading library…");
        view.show_loading_view ();
        foreach (var game in Replay.Core.Client.get_default ().game_library.get_games ()) {
            var cores = Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (game.rom_path));
            var core_names = new Gee.ArrayList<string> ();
            foreach (var core in cores) {
                core_names.add (core.info.core_name);
            }
            view.add_game (game);
        }
        view.expand_systems_category ();
        view.hide_loading_view ();
    }

    public void show_preferences_dialog () {
        if (preferences_dialog == null) {
            preferences_dialog = new Replay.Widgets.Dialogs.PreferencesDialog (this);
            preferences_dialog.show_all ();
            preferences_dialog.destroy.connect (() => {
                preferences_dialog = null;
            });
        }
        preferences_dialog.present ();
    }

    public void show_about_dialog () {
        if (about_dialog == null) {
            about_dialog = new Replay.Widgets.Dialogs.AboutDialog (this);
            about_dialog.show_all ();
            about_dialog.destroy.connect (() => {
                about_dialog = null;
            });
        }
        about_dialog.present ();
    }

    public void toggle_sidebar () {
        view.toggle_sidebar ();
    }

    public void show_processing (bool processing) {
        view.show_processing (processing);
    }

    private void launch_game (Replay.Models.Game game, string? specified_core_name) {
        Replay.Models.LibretroCore? specified_core = specified_core_name == null ? null : Replay.Core.Client.get_default ().core_repository.get_core_by_name (specified_core_name);
        Replay.Core.Client.get_default ().emulator_manager.launch_game (game, specified_core);
    }

}
