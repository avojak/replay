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
