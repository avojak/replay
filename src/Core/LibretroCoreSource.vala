/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public interface Replay.Core.LibretroCoreSource : GLib.Object {

    public abstract Gee.Collection<Replay.Models.LibretroCore> scan ();

}
