/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Models.VideoFilterMapping : GLib.Object {

    private static GLib.Once<Gee.Map<Retro.VideoFilter, string>> display_strings;
    public static unowned Gee.Map<Retro.VideoFilter, string> get_display_strings () {
        return display_strings.once (() => {
            var _display_strings = new Gee.HashMap<Retro.VideoFilter, string> ();
            _display_strings.set (Retro.VideoFilter.SHARP, _("Sharp"));
            _display_strings.set (Retro.VideoFilter.SMOOTH, _("Smooth"));
            _display_strings.set (Retro.VideoFilter.CRT, _("CRT"));
            return _display_strings;
        });
    }

    private static GLib.Once<Gee.Map<Retro.VideoFilter, string>> descriptions;
    public static unowned Gee.Map<Retro.VideoFilter, string> get_descriptions () {
        return descriptions.once (() => {
            var _descriptions = new Gee.HashMap<Retro.VideoFilter, string> ();
            _descriptions.set (Retro.VideoFilter.SHARP, _("Shows every pixel"));
            _descriptions.set (Retro.VideoFilter.SMOOTH, _("Smooth but blurry"));
            _descriptions.set (Retro.VideoFilter.CRT, _("Mimicks CRT screens"));
            return _descriptions;
        });
    }

    public static string get_short_name (Retro.VideoFilter filter) {
        switch (filter) {
            case SHARP:
                return "SHARP";
            case SMOOTH:
                return "SMOOTH";
            case CRT:
                return "CRT";
            default:
                assert_not_reached ();
        }
    }

    public static Retro.VideoFilter from_short_name (string short_name) {
        switch (short_name) {
            case "SHARP":
                return SHARP;
            case "SMOOTH":
                return SMOOTH;
            case "CRT":
                return CRT;
            default:
                assert_not_reached ();
        }
    }

}
