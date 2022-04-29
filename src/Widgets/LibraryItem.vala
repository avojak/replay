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

public class Replay.Widgets.LibraryItem : Gtk.FlowBoxChild {

    public unowned Replay.Models.Game game { get; construct; }
    public string title { get; construct; }

    private Gtk.Revealer unplayed_badge;
    private Gtk.Revealer play_button;

    public LibraryItem.for_game (Replay.Models.Game game) {
        Object (
            game: game,
            title: game.display_name
        );
    }

    construct {
        get_style_context ().add_class ("library-item");

        // TODO: Fix alignment when the labels spans multiple lines - the images won't currently lineup
        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
            margin = 8
        };
        Gtk.Image? image;
        try {
            string? box_art_file_path = Replay.Core.Client.get_default ().game_art_repository.get_box_art_file_path (game);
            if (box_art_file_path == null) {
                image = new Gtk.Image () {
                    gicon = new ThemedIcon ("application-default-icon"),
                    pixel_size = 128,
                    margin_bottom = 8
                };
            } else {
                image = new Gtk.Image.from_pixbuf (new Gdk.Pixbuf.from_file_at_size (box_art_file_path, 100, 100)) {
                    margin_top = 16,
                    margin_start = 16,
                    margin_end = 16,
                    margin_bottom = 20
                };
            }
        } catch (GLib.Error e) {
            image = new Gtk.Image () {
                gicon = new ThemedIcon ("application-default-icon"),
                pixel_size = 128,
                margin_bottom = 8
            };
        }
        var badge = new Gtk.Label (null) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.START,
            use_markup = true
        };
        badge.set_markup ("<b>!</b>");
        badge.get_style_context ().add_class (Granite.STYLE_CLASS_BADGE);
        var unplayed_image = new Gtk.Image () {
            gicon = new ThemedIcon ("mail-unread"),
            pixel_size = 32
        };
        unplayed_badge = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.NONE,
            halign = Gtk.Align.START,
            valign = Gtk.Align.START
        };
        unplayed_badge.add (unplayed_image);
        var play_image = new Gtk.Image () {
            gicon = new ThemedIcon ("media-playback-start"),
            pixel_size = 32,
            sensitive = false
        };
        play_button = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.NONE,
            halign = Gtk.Align.START,
            valign = Gtk.Align.END
        };
        play_button.add (play_image);
        var overlay = new Gtk.Overlay () {
            halign = Gtk.Align.CENTER
        };
        //  overlay.add_overlay (badge); // TODO: Could use an icon here probably
        overlay.add (image);
        overlay.add_overlay (unplayed_badge);
        overlay.add_overlay (play_button);
        // TODO: Add favorites icon badge? Or would that be too busy?
        //  overlay.set_tooltip_text ("Game could not be found");

        var label_grid = new Gtk.Grid () {
            hexpand = true,
            vexpand = true,
            margin_bottom = 8,
            halign = Gtk.Align.CENTER
        };

        //  var unplayed_image = new Gtk.Image () {
        //      gicon = new ThemedIcon ("mail-unread"),
        //      pixel_size = 16,
        //      margin_right = 8
        //  };
        //  unplayed_badge = new Gtk.Revealer () {
        //      transition_type = Gtk.RevealerTransitionType.NONE,
        //      valign = Gtk.Align.START
        //  };
        //  unplayed_badge.add (unplayed_image);

        var label = new Gtk.Label (null) {
            wrap = true,
            max_width_chars = 20,
            justify = Gtk.Justification.CENTER,
            //  margin_bottom = 8,
            use_markup = true
        };
        label.set_markup (@"<b>$title</b>");

        //  label_grid.attach (unplayed_badge, 0, 0);
        label_grid.attach (label, 1, 0);

        grid.add (overlay);
        grid.add (label_grid);

        //  var style_context = get_style_context ();
        //  style_context.add_class (Granite.STYLE_CLASS_CARD);
        //  style_context.add_class (Granite.STYLE_CLASS_ROUNDED);

        //  var event_box = new Gtk.EventBox ();
        //  event_box.add (grid);
        //  event_box.set_events (Gdk.EventMask.ENTER_NOTIFY_MASK);
        //  event_box.set_events (Gdk.EventMask.LEAVE_NOTIFY_MASK);

        //  event_box.enter_notify_event.connect (() => {
        //      debug ("enter event box");
        //      play_button.set_reveal_child (true);
        //  });
        //  event_box.leave_notify_event.connect (() => {
        //      debug ("leave event box");
        //      play_button.set_reveal_child (false);
        //  });

        //  child = event_box;
        child = grid;

        set_played (game.is_played);

        //  enter_notify_event.connect (() => {
        //      debug ("enter");
        //      
        //  });
        //  leave_notify_event.connect (() => {
        //      debug ("leave");
        //      
        //  });

        show_all ();
    }

    public void set_played (bool played) {
        // Only change the revealer if the desired state is different from the current
        // TODO: Can we instead listen for a change to the property of the game?
        if (played == unplayed_badge.child_revealed) {
            unplayed_badge.set_reveal_child (!played);
        }
    }

    public void set_favorite (bool favorite) {
    }

    public void set_visible (bool visible) {
        //  this.hide ();
        this.visible = visible;
    }

}
