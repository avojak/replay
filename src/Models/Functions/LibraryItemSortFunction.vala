/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

/**
 * Base sort function for sorting items in the library view.
 */
public abstract class Replay.Models.Functions.LibraryItemSortFunction : GLib.Object {

    public abstract int sort (Replay.Widgets.LibraryItem a, Replay.Widgets.LibraryItem b);

}

public class Replay.Models.Functions.AlphabeticalSortFunction : Replay.Models.Functions.LibraryItemSortFunction {

    public override int sort (Replay.Widgets.LibraryItem a, Replay.Widgets.LibraryItem b) {
        return a.game.display_name.ascii_casecmp (b.game.display_name);
    }

}

public class Replay.Models.Functions.LastPlayedSortFunction : Replay.Models.Functions.LibraryItemSortFunction {

    public override int sort (Replay.Widgets.LibraryItem a, Replay.Widgets.LibraryItem b) {
        if (a.game.last_played == null || b.game.last_played == null) {
            // Don't need to get fancy here - if one or both are null, the visual filter will take care of it anyway
            return 0;
        }
        return -1 * a.game.last_played.compare (b.game.last_played);
    }

}
