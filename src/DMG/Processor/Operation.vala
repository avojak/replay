/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Replay.DMG.Processor.Operation : GLib.Object {

    public string description { get; construct; }
    // The length of the operation (in bytes)
    public int length { get; construct; }
    //
    public int ticks { get; construct; }

    private Lambda exec;

    public Operation (string description, Lambda exec, int length, int ticks) {
        Object (
            description: description,
            ticks: ticks,
            length: length
        );
        this.exec = exec;
    }

    public int execute (Replay.DMG.Processor.CPU cpu) {
        int result = exec (cpu);
        return result;
    }

    public delegate int Lambda (Replay.DMG.Processor.CPU cpu);

}
