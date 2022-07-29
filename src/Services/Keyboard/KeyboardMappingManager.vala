/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

// https://gitlab.gnome.org/Archive/gnome-games/-/blob/master/src/keyboard/keyboard-mapping-manager.vala
public class Replay.Services.Keyboard.KeyboardMappingManager : GLib.Object {

    private const string MAPPING_FILENAME = "keyboard-mapping.txt";
    private const string GROUP_NAME = "KeyboardMapping";

    public Retro.KeyJoypadMapping mapping { get; private set; }

    private GLib.File mapping_file;

    construct {
        mapping_file = GLib.File.new_for_path (GLib.Path.build_filename (GLib.Environment.get_user_config_dir (), MAPPING_FILENAME));

        load_mapping ();
    }

    private void load_mapping () {
        if (!mapping_file.query_exists ()) {
            debug ("User keyboard mapping doesn't exist");
            mapping = new Retro.KeyJoypadMapping.default ();
            changed ();
            return;
        }

        mapping = new Retro.KeyJoypadMapping ();
        var mapping_key_file = new GLib.KeyFile ();
        try {
            mapping_key_file.load_from_file (mapping_file.get_path (), GLib.KeyFileFlags.NONE);
        } catch (GLib.Error e) {
            critical (e.message);
            changed ();
            return;
        }

        var enumc = (EnumClass) typeof (Retro.JoypadId).class_ref ();
        foreach (var id in enumc.values) {
            var button = id.value_nick;
            try {
                var key = mapping_key_file.get_integer (GROUP_NAME, button);
                mapping.set_button_key ((Retro.JoypadId) id.value, (uint16) key);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }

        changed ();
    }

    public bool is_default () {
        return !mapping_file.query_exists ();
    }

    public void save_mapping (Retro.KeyJoypadMapping mapping) {
        var mapping_key_file = new GLib.KeyFile ();
        var enumc = (EnumClass) typeof (Retro.JoypadId).class_ref ();
        foreach (var id in enumc.values) {
            var button = id.value_nick;
            var key = mapping.get_button_key ((Retro.JoypadId) id.value);
            mapping_key_file.set_integer (GROUP_NAME, button, key);
        }

        try {
            mapping_key_file.save_to_file (mapping_file.get_path ());
        } catch (GLib.Error e) {
            critical (e.message);
        }
    }

    public void delete_mapping () {
        if (!mapping_file.query_exists ()) {
            return;
        }
        try {
            mapping_file.delete ();
        } catch (GLib.Error e) {
            critical (e.message);
        }
    }

    public signal void changed ();

}
