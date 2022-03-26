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

public class Replay.Models.LibraryItemSortFunction : GLib.Object {

    public Sort sort { get; set; }

    public LibraryItemSortFunction (Sort sort) {
        this.sort = sort;
    }

    /*
     * Return < 0 if child1 should be before child2, 0 if the are equal, and > 0 otherwise.
     */
    public delegate int Sort (Replay.Widgets.LibraryItem library_item_1, Replay.Widgets.LibraryItem library_item_2);

}
