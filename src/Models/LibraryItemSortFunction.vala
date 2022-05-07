/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
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
