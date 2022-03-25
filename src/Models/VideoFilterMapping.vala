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

}
