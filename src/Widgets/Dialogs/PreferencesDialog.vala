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

public class Replay.Widgets.Dialogs.PreferencesDialog : Hdy.Window {

    public Replay.Windows.LibraryWindow library_window {get; construct; }

    public PreferencesDialog (Replay.Windows.LibraryWindow library_window) {
        Object (
            title: _("%s Preferences").printf (Constants.APP_NAME),
            deletable: true,
            resizable: true,
            transient_for: library_window,
            library_window: library_window,
            modal: false
        );
    }

    construct {
        add (new Replay.Views.Settings.SettingsView ());
        var width = 700;
        var height = 500;
        resize (width, height);
        
        int library_window_width;
        int library_window_height;
        int library_window_x;
        int library_window_y;
        library_window.get_size (out library_window_width, out library_window_height);
        library_window.get_position (out library_window_x, out library_window_y);

        var x = library_window_x + (library_window_width / 2) - (width / 2);
        var y = library_window_y + (library_window_height / 2) - (height / 2);
        move (x, y);
    }

}
