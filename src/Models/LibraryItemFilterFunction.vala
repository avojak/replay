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

public class Replay.Models.LibraryItemFilterFunction : GLib.Object {

    public string placeholder_title { get; set; }
    public string placeholder_description { get; set; }
    public string placeholder_icon_name { get; set; }

    public Filter filter { get; set; }

    public LibraryItemFilterFunction (string placeholder_title, string placeholder_description, string placeholder_icon_name, Filter filter) {
        Object (
            placeholder_title: placeholder_title,
            placeholder_description: placeholder_description,
            placeholder_icon_name: placeholder_icon_name
        );
        this.filter = filter;
    }

    public delegate bool Filter (Replay.Widgets.LibraryItem library_item);

}
