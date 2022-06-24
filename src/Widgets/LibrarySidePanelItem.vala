/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.LibrarySidePanelItem : Granite.Widgets.SourceList.Item {

    public string view_name { get; construct; }

    public LibrarySidePanelItem (string name, string icon_name, string view_name) {
        Object (
            name: name,
            icon: new GLib.ThemedIcon (icon_name),
            view_name: view_name
        );
    }

}
