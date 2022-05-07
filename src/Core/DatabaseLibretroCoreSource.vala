/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Core.DatabaseLibretroCoreSource : Replay.Core.LibretroCoreSource, GLib.Object {

    public Gee.Collection<Replay.Models.LibretroCore> scan () {
        return Replay.Core.Client.get_default ().core_repository.get_cores ();
    }

}
