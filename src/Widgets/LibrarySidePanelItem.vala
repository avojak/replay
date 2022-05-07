/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.LibrarySidePanelItem : Granite.Widgets.SourceList.Item {

    public string view_name { get; construct; }
    //  public Replay.Views.LibraryView.FilterFunc? filter_func { get; set; }

    public LibrarySidePanelItem (string name, string icon_name, string view_name) {
        Object (
            name: name,
            icon: new GLib.ThemedIcon (icon_name),
            view_name: view_name
        );
    }

    //  public delegate bool FilterFunc (Replay.Widgets.LibraryItem item);

    //  public bool filter_func (Replay.Models.Game game) {
    //      Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (game.rom_path));
    //      return true;
    //  }

    //  public void increment_badge () {
    //      this.badge = (int.parse (this.badge) + 1).to_string ();
    //  }

    //  public void decrement_badge () {
    //      this.badge = (int.parse (this.badge) + 1).to_string ();
    //  }

}
