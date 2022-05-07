/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.LibraryWindowActionManager : GLib.Object {

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_QUIT = "action_quit";
    public const string ACTION_PREFERENCES = "action_preferences";
    public const string ACTION_TOGGLE_SIDEBAR = "action_toggle_sidebar";
    public const string ACTION_SHOW_FIND = "action_show_find";
    public const string ACTION_HIDE_FIND = "action_hide_find";

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_QUIT, action_quit },
        { ACTION_PREFERENCES, action_preferences },
        { ACTION_TOGGLE_SIDEBAR, action_toggle_sidebar },
        { ACTION_SHOW_FIND, action_show_find },
        { ACTION_HIDE_FIND, action_hide_find }
    };

    private static Gee.MultiMap<string, string> accelerators;

    public unowned Replay.Application application { get; construct; }
    public unowned Replay.Windows.LibraryWindow window { get; construct; }

    private static GLib.SimpleActionGroup action_group;

    public LibraryWindowActionManager (Replay.Application application, Replay.Windows.LibraryWindow window) {
        Object (
            application: application,
            window: window
        );
    }

    static construct {
        accelerators = new Gee.HashMultiMap<string, string> ();
        accelerators.set (ACTION_QUIT, "<Control>q");
        accelerators.set (ACTION_PREFERENCES, "<Control><Shift>p");
        accelerators.set (ACTION_TOGGLE_SIDEBAR, "<Control>backslash");
        accelerators.set (ACTION_SHOW_FIND, "<Control>f");
    }

    construct {
        action_group = new GLib.SimpleActionGroup ();
        action_group.add_action_entries (ACTION_ENTRIES, this);
        window.insert_action_group ("win", action_group);

        foreach (var action in accelerators.get_keys ()) {
            var accelerators_array = accelerators[action].to_array ();
            accelerators_array += null;
            application.set_accels_for_action (ACTION_PREFIX + action, accelerators_array);
        }

        action_group.action_state_changed.connect ((name, new_state) => {
            if (name == ACTION_SHOW_FIND) {
                if (new_state.get_boolean () == false) {
                    //  window.set_searchbar_visible (new_state.get_boolean ());
                    //  toolbar.find_button.tooltip_markup = Granite.markup_accel_tooltip (
                    //      app.get_accels_for_action (ACTION_PREFIX + ACTION_FIND),
                    //      _("Find…")
                    //  );
                } else {
                    //  toolbar.find_button.tooltip_markup = Granite.markup_accel_tooltip (
                    //      {"Escape"},
                    //      _("Hide search bar")
                    //  );
                }
                //  search_revealer.set_reveal_child (new_state.get_boolean ());

                //  window.set_searchbar_visible (new_state.get_boolean ());
            }
        });
    }

    //  public static void set_action_state (string action_name, bool state) {
    //      ((SimpleAction) action_group.lookup_action (action_name)).set_state (state);
    //  }

    public static void action_from_group (string action_name, GLib.ActionGroup action_group, GLib.Variant? parameter = null) {
        action_group.activate_action (action_name, parameter);
    }

    private void action_quit () {
        window.before_destroy ();
    }

    private void action_preferences () {
        window.show_preferences_dialog ();
    }

    private void action_toggle_sidebar () {
        window.toggle_sidebar ();
    }

    private void action_show_find () {
        window.set_searchbar_visible (true);
    }

    private void action_hide_find () {
        window.set_searchbar_visible (false);
    }

}
