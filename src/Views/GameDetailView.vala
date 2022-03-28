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

public class Replay.Views.GameDetailView : Gtk.Grid {

    private Replay.Models.Game? game;

    private Gtk.Label header_title_label;

    public GameDetailView () {
        Object (
            expand: true,
            margin: 30
        );
    }

    construct {
        // Create the header
        var header_grid = new Gtk.Grid () {
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 10,
            hexpand = true
        };

        var header_image = new Gtk.Image () {
            gicon = new ThemedIcon ("application-default-icon"),
            pixel_size = 128
        };

        header_title_label = new Gtk.Label ("") {
            valign = Gtk.Align.END,
            halign = Gtk.Align.START,
            hexpand = true
        };
        header_title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
        header_title_label.set_line_wrap (true);

        var play_button = new Gtk.Button () {
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
            always_show_image = true,
            image = new Gtk.Image.from_icon_name ("media-playback-start", Gtk.IconSize.SMALL_TOOLBAR),
            image_position = Gtk.PositionType.LEFT,
            label = _("Play")
        };
        play_button.clicked.connect (() => {
            play_button_clicked (game);
        });

        header_grid.attach (header_image, 0, 0, 1, 2);
        header_grid.attach (header_title_label, 1, 0, 1, 1);
        header_grid.attach (play_button, 1, 1, 1, 1);

        var body_grid = new Gtk.Grid () {
            expand = true
        };

        attach (header_grid, 0, 0);
        attach (body_grid, 0, 1);
    }

    public void set_game (Replay.Models.Game game) {
        this.game = game;
        header_title_label.set_text (game.display_name);
    }

    public signal void play_button_clicked (Replay.Models.Game game);

}
