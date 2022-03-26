/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
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
            expand = true
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
