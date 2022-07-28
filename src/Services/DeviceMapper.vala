/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public interface Replay.Services.DeviceMapper<T> : GLib.Object {

    public abstract void connect_to_device ();
    public abstract void disconnect_from_device ();
    public abstract void start ();
    public abstract void stop ();
    public abstract void skip ();

    public signal void prompt (string prompt);
    public signal void finished (T result);

}
