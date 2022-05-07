/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
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
