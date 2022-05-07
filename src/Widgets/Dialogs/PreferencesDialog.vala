/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.Dialogs.PreferencesDialog : Granite.Dialog {

    public Replay.Windows.LibraryWindow library_window {get; construct; }

    public PreferencesDialog (Replay.Windows.LibraryWindow library_window) {
        Object (
            title: _("%s Preferences").printf (Constants.APP_NAME),
            deletable: false,
            resizable: false,
            transient_for: library_window,
            modal: false,
            library_window: library_window
        );
    }

    construct {
        var stack_grid = new Gtk.Grid () {
            expand = true,
            height_request = 500,
            width_request = 500
        };

        var stack_switcher = new Gtk.StackSwitcher () {
            halign = Gtk.Align.CENTER
        };
        stack_grid.attach (stack_switcher, 0, 0, 1, 1);

        var stack = new Gtk.Stack () {
            expand = true
        };
        stack_switcher.stack = stack;

        stack.add_titled (new Replay.Views.Settings.BehaviorSettingsView (), "behavior", _("Behavior"));
        stack.add_titled (new Replay.Views.Settings.InterfaceSettingsView (), "interface", _("Interface"));
        stack.add_titled (new Replay.Views.Settings.SystemsSettingsView (), "systems", _("Systems"));
        stack_grid.attach (stack, 0, 1, 1, 1);

        get_content_area ().add (stack_grid);

        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (close_button, 0);

        load_settings ();
    }

    private void load_settings () {

    }

}
