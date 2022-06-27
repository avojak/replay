/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Services.EmulatorWindowActionManager : GLib.Object {

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_QUIT = "action_quit";

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_QUIT, action_quit }
    };

    private static Gee.MultiMap<string, string> accelerators;

    public unowned Replay.Application application { get; construct; }
    public unowned Replay.Windows.EmulatorWindow window { get; construct; }

    private static GLib.SimpleActionGroup action_group;

    public EmulatorWindowActionManager (Replay.Application application, Replay.Windows.EmulatorWindow window) {
        Object (
            application: application,
            window: window
        );
    }

    static construct {
        accelerators = new Gee.HashMultiMap<string, string> ();
        accelerators.set (ACTION_QUIT, "<Control>q");
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
    }

    public static void action_from_group (string action_name, GLib.ActionGroup action_group, GLib.Variant? parameter = null) {
        action_group.activate_action (action_name, parameter);
    }

    private void action_quit () {
        window.before_destroy ();
    }

}
